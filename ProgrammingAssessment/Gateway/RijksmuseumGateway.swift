import Foundation

enum CollectionLoadingError: Error {
    case parsingError(Error)
    case serviceError(ServiceLoadingError)
}

enum CollectionImageLoadingError: Error {
    case serviceError(ServiceLoadingError)
}

enum ArtDetailsLoadingError: Error {
    case parsingError(Error)
    case serviceError(ServiceLoadingError)
}

enum ArtDetailsImageLoadingError: Error {
    case serviceError(ServiceLoadingError)
}

typealias CollectionLoadingResult = Result<CollectionPage, CollectionLoadingError>
typealias CollectionLoadingResultHandler = (CollectionLoadingResult) -> Void

typealias CollectionImageLoadingResult = Result<Data, CollectionImageLoadingError>
typealias CollectionImageLoadingResultHandler = (CollectionImageLoadingResult) -> Void

typealias ArtDetailsLoadingResult = Result<ArtDetails, ArtDetailsLoadingError>
typealias ArtDetailsLoadingResultHandler = (ArtDetailsLoadingResult) -> Void

typealias ArtDetailsImageLoadingResult = Result<Data, ArtDetailsImageLoadingError>
typealias ArtDetailsImageLoadingResultHandler = (ArtDetailsImageLoadingResult) -> Void

typealias ArtImageDataLoadingResult = Result<Data, ServiceLoadingError>
typealias ArtImageDataLoadingResultHandler = (ArtImageDataLoadingResult) -> Void

protocol ArtGateway {
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler)
    func loadCollectionImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler)
    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler)
    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler)
}

class RijksmuseumArtGateway: ArtGateway {

    enum CollectionImageLoadingScale: Int {
        case original = 0
        case thumbnail = 400
    }

    let service: ServiceLoading

    init(service: ServiceLoading) {
        self.service = service
    }
    
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {
        let query = RijksmuseumServiceQuery(request: .all).withPage(page: page).withPageSize(pageSize: count)

        service.getData(query: query) { result in
            switch result {
            case let .success(data):
                do {
                    let collectionInof = try JSONDecoder().decode(CollectionInfo.self, from: data)
                    let collectionPage = CollectionPage(title: "Page \(page)", items: collectionInof.collectionItems)
                    DispatchQueue.main.async {
                        completion(.success( collectionPage ))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.parsingError(error)))
                    }
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.serviceError(error)))
                }
            }
        }
    }

    func loadCollectionImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {
        loadArtImageData(from: url, scale: .thumbnail) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.serviceError(error)))
            }
        }
    }

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
        let query = RijksmuseumServiceQuery(request: .collection(artId))

        service.getData(query: query) { result in
            switch result {
            case let .success(data):
                do {
                    let artDetailsInfo = try JSONDecoder().decode(ArtDetailsInfo.self, from: data)
                    let artDetails = artDetailsInfo.artDetails
                    DispatchQueue.main.async {
                        completion(.success( artDetails ))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.parsingError(error)))
                    }
                }
                break
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.serviceError(error)))
                }
            }
        }
    }

    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
        loadArtImageData(from: url, scale: .original) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.serviceError(error)))
            }
        }
    }

    private func loadArtImageData(from url: URL,
                                  scale: CollectionImageLoadingScale,
                                  completion: @escaping ArtImageDataLoadingResultHandler) {
        var urlString = url.absoluteString
        urlString.removeLast()
        let query = RijksmuseumImageQuery(url: urlString).withScale(scale: scale.rawValue)
        service.getData(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    completion(.success( data))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}

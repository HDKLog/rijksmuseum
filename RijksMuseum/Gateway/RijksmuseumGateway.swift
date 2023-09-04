import Foundation
import Combine

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

typealias CollectionLoadingResult = Result<CollectionInfo, CollectionLoadingError>
typealias CollectionLoadingResultHandler = (CollectionLoadingResult) -> Void

typealias CollectionImageLoadingResult = Result<Data, CollectionImageLoadingError>
typealias CollectionImageLoadingResultHandler = (CollectionImageLoadingResult) -> Void

typealias ArtDetailsLoadingResult = Result<ArtDetailsInfo, ArtDetailsLoadingError>
typealias ArtDetailsLoadingResultHandler = (ArtDetailsLoadingResult) -> Void

typealias ArtDetailsImageLoadingResult = Result<Data, ArtDetailsImageLoadingError>
typealias ArtDetailsImageLoadingResultHandler = (ArtDetailsImageLoadingResult) -> Void

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
    
    typealias ArtImageDataLoadingResult = Result<Data, ServiceLoadingError>
    typealias ArtImageDataLoadingResultHandler = (ArtImageDataLoadingResult) -> Void

    let service: ServiceLoading

    var cancelables: [AnyCancellable] = []

    init(service: ServiceLoading) {
        self.service = service
    }
    
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {
        let query = RijksmuseumServiceQuery(request: .all).withPage(page: page).withPageSize(pageSize: count)

        let publisher = service.getData(query: query)
            .mapError(CollectionLoadingError.serviceError)
            .eraseToAnyPublisher()


        publisher
            .receive(on: DispatchQueue.main)
            .flatMap { data -> AnyPublisher<CollectionInfo, CollectionLoadingError> in
                do {
                    let collectionInfo = try JSONDecoder().decode(CollectionInfo.self, from: data)
                    return Just(collectionInfo).setFailureType(to: CollectionLoadingError.self).eraseToAnyPublisher()
                } catch {
                    return Fail<CollectionInfo, CollectionLoadingError>(error: .parsingError(error)).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 { completion(.failure(error)) }
            }, receiveValue: {
                completion(.success($0))
            })
            .store(in: &cancelables)
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

        let publisher = service.getData(query: query)
            .mapError(ArtDetailsLoadingError.serviceError)
            .eraseToAnyPublisher()

        publisher
            .receive(on: DispatchQueue.main)
            .flatMap { data -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError> in
                do {
                    let artInfo = try JSONDecoder().decode(ArtDetailsInfo.self, from: data)
                    return Just(artInfo).setFailureType(to: ArtDetailsLoadingError.self).eraseToAnyPublisher()
                } catch {
                    return Fail<ArtDetailsInfo, ArtDetailsLoadingError>(error: .parsingError(error)).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 { completion(.failure(error)) }
            }, receiveValue: {
                completion(.success($0))
            })
            .store(in: &cancelables)

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

        service.getData(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 { completion(.failure(error)) }
            }, receiveValue: {
                completion(.success($0))
            })
            .store(in: &cancelables)
    }
}

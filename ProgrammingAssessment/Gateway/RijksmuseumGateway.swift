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

protocol ArtGateway {
    func loadCollection(page: Int, count: Int) -> AnyPublisher<CollectionInfo, CollectionLoadingError>
    func loadCollectionImageData(from url: URL) -> AnyPublisher<Data, CollectionImageLoadingError>
    func loadArtDetails(artId: String) -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError>
    func loadArtDetailsImageData(from url: URL) -> AnyPublisher<Data, ArtDetailsImageLoadingError>
}

class RijksmuseumArtGateway: ArtGateway {

    enum CollectionImageLoadingScale: Int {
        case original = 0
        case thumbnail = 400
    }
    
    typealias ArtImageDataLoadingResult = Result<Data, ServiceLoadingError>
    typealias ArtImageDataLoadingResultHandler = (ArtImageDataLoadingResult) -> Void

    let service: ServiceLoading

    init(service: ServiceLoading) {
        self.service = service
    }
    
    func loadCollection(page: Int, count: Int) -> AnyPublisher<CollectionInfo, CollectionLoadingError> {
        let query = RijksmuseumServiceQuery(request: .all).withPage(page: page).withPageSize(pageSize: count)

        let publisher = service.getData(query: query)
            .mapError(CollectionLoadingError.serviceError)
            .eraseToAnyPublisher()


        return publisher
            .flatMap { data -> AnyPublisher<CollectionInfo, CollectionLoadingError> in
                do {
                    let collectionInfo = try JSONDecoder().decode(CollectionInfo.self, from: data)
                    return Just(collectionInfo).setFailureType(to: CollectionLoadingError.self).eraseToAnyPublisher()
                } catch {
                    return Fail<CollectionInfo, CollectionLoadingError>(error: .parsingError(error)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func loadCollectionImageData(from url: URL) -> AnyPublisher<Data, CollectionImageLoadingError> {
        loadArtImageData(from: url, scale: .thumbnail)
            .mapError(CollectionImageLoadingError.serviceError)
            .eraseToAnyPublisher()
    }

    func loadArtDetails(artId: String) -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError> {
        let query = RijksmuseumServiceQuery(request: .collection(artId))

        let publisher = service.getData(query: query)
            .mapError(ArtDetailsLoadingError.serviceError)
            .eraseToAnyPublisher()

        return publisher
            .flatMap { data -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError> in
                do {
                    let artInfo = try JSONDecoder().decode(ArtDetailsInfo.self, from: data)
                    return Just(artInfo).setFailureType(to: ArtDetailsLoadingError.self).eraseToAnyPublisher()
                } catch {
                    return Fail<ArtDetailsInfo, ArtDetailsLoadingError>(error: .parsingError(error)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

    }

    func loadArtDetailsImageData(from url: URL) -> AnyPublisher<Data, ArtDetailsImageLoadingError> {
        loadArtImageData(from: url, scale: .original)
            .mapError(ArtDetailsImageLoadingError.serviceError)
            .eraseToAnyPublisher()
    }

    private func loadArtImageData(from url: URL,
                                  scale: CollectionImageLoadingScale) -> AnyPublisher<Data, ServiceLoadingError> {
        var urlString = url.absoluteString
        urlString.removeLast()
        let query = RijksmuseumImageQuery(url: urlString).withScale(scale: scale.rawValue)

        return service.getData(query: query).eraseToAnyPublisher()
    }
}

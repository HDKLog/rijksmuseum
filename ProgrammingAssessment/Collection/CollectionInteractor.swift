import Foundation

enum CollectionLoadingError: Error {
    case parsingError(Error)
    case serviceError(ServiceLoadingError)
}

typealias CollectionLoadingResult = Result<CollectionPage, CollectionLoadingError>
typealias CollectionLoadingResultHandler = (CollectionLoadingResult) -> Void

enum CollectionImageLoadingScale: Int {
    case original = 0
    case thumbnail = 400
}

typealias CollectionImageLoadingResult = Result<Data, Error>
typealias CollectionImageLoadingResultHandler = (CollectionImageLoadingResult) -> Void

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler)
    func loadCollectionItemImageData(from url: URL,
                                     scale: CollectionImageLoadingScale,
                                     completion: @escaping CollectionImageLoadingResultHandler
    )
}

class CollectionInteractor: CollectionInteracting {

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

    func loadCollectionItemImageData(from url: URL,
                                     scale: CollectionImageLoadingScale,
                                     completion: @escaping CollectionImageLoadingResultHandler) {

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

extension CollectionInfo {
    typealias CollectionItem = CollectionPage.CollectionItem
    typealias Image = CollectionPage.CollectionItem.Image

    var collectionItems: [CollectionItem] {
        artObjects.map {
            CollectionItem(
                id: $0.objectNumber,
                title: $0.title,
                description: $0.longTitle,
                webImage: Image(
                    guid: $0.webImage.guid,
                    width: $0.webImage.width,
                    height: $0.webImage.height,
                    url: URL(string: $0.webImage.url)
                ),
                headerImage: Image(
                    guid: $0.headerImage.guid,
                    width: $0.headerImage.width,
                    height: $0.headerImage.height,
                    url: URL(string: $0.headerImage.url)
                )
            )
        }
    }
}

import Foundation

enum CollectionError: Error {
    case loading(error: CollectionLoadingError)
}

enum CollectionImageDataError: Error {
    case loading(error: CollectionImageLoadingError)
}

typealias CollectionResult = Result<CollectionPage, CollectionError>
typealias CollectionResultHandler = (CollectionResult) -> Void

typealias CollectionImageDataResult = Result<Data, CollectionImageDataError>
typealias CollectionImageDataResultHandler = (CollectionImageDataResult) -> Void

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionResultHandler)
    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageDataResultHandler)
}

class CollectionInteractor: CollectionInteracting {

    let gateway: ArtGateway

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionResultHandler) {

        gateway.loadCollection(page: page, count: count) { result in
            switch result {
            case let .success(info):
                let collectionPage = CollectionPage(title: "Page \(page)", items: info.collectionItems)
                completion(.success(collectionPage))
            case let .failure(error):
                completion(.failure(.loading(error: error)))
            }
        }
    }

    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageDataResultHandler) {
        gateway.loadCollectionImageData(from: url) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.loading(error: error)))
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

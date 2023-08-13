import Foundation

typealias CollectionLoadingResult = Result<CollectionPage, Error>
typealias CollectionLoadingResultHandler = (CollectionLoadingResult) -> Void

typealias CollectionImageLoadingResult = Result<Data, Error>
typealias CollectionImageLoadingResultHandler = (CollectionImageLoadingResult) -> Void

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler)
    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler)
}

class CollectionInteractor: CollectionInteracting {

    let service: ServiceLoading

    init(service: ServiceLoading) {
        self.service = service
    }

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {

        service.loadCollection(page: page, count: count) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(collectionInof):
                    completion(.success( CollectionPage(title: "Page \(page)", items: collectionInof.collectionItems) ))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {

        service.loadImage(url: url) { result in
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

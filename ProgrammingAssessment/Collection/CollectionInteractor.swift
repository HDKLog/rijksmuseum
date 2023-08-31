import Foundation

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler)
    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler)
}

class CollectionInteractor: CollectionInteracting {

    let gateway: ArtGateway

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {

        gateway.loadCollection(page: page, count: count, completion: completion)
    }

    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {
        gateway.loadCollectionImageData(from: url, completion: completion)
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

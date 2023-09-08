import Foundation
import Combine

enum CollectionError: Error {
    case loading(error: CollectionLoadingError)
}

enum CollectionImageDataError: Error {
    case loading(error: CollectionImageLoadingError)
}

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int) -> AnyPublisher<CollectionPage, CollectionError>
    func loadCollectionItemImageData(from url: URL) -> AnyPublisher<Data, CollectionImageDataError>
}

class CollectionInteractor: CollectionInteracting {

    let gateway: ArtGateway

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadCollection(page: Int, count: Int) -> AnyPublisher<CollectionPage, CollectionError> {

        gateway.loadCollection(page: page, count: count)
            .receive(on: DispatchQueue.main)
            .mapError(CollectionError.loading)
            .map { CollectionPage(title: "Page \(page)", items: $0.collectionItems) }
            .eraseToAnyPublisher()
    }

    func loadCollectionItemImageData(from url: URL) -> AnyPublisher<Data, CollectionImageDataError> {
        gateway.loadCollectionImageData(from: url)
            .receive(on: DispatchQueue.main)
            .mapError(CollectionImageDataError.loading)
            .eraseToAnyPublisher()
    }
}

extension CollectionInfo {
    typealias CollectionItem = CollectionPage.CollectionItem


    var collectionItems: [CollectionItem] {
        artObjects.map {
            CollectionItem(
                id: $0.objectNumber,
                title: $0.title,
                description: $0.longTitle,
                webImage: $0.webImage?.collectionItemImage,
                headerImage: $0.headerImage?.collectionItemImage
            )
        }
    }
}

extension CollectionInfo.Art.ImageInfo {
    typealias Image = CollectionPage.CollectionItem.Image
    var collectionItemImage: Image {
        Image(
            guid: guid,
            width: width,
            height: height,
            url: url.flatMap { URL(string: $0) }
        )
    }
}

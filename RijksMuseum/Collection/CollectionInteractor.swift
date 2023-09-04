import Foundation
import Combine

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

    var cancelables: [AnyCancellable] = []

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionResultHandler) {

        gateway.loadCollection(page: page, count: count)
            .receive(on: DispatchQueue.main)
            .mapError(CollectionError.loading)
            .map { CollectionPage(title: "Page \(page)", items: $0.collectionItems) }
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    completion(.failure(error))
                }
            }, receiveValue: {
                completion(.success($0))
            })
            .store(in: &cancelables)
    }

    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageDataResultHandler) {
        gateway.loadCollectionImageData(from: url)
            .receive(on: DispatchQueue.main)
            .mapError(CollectionImageDataError.loading)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    completion(.failure(error))
                }
            }, receiveValue: {
                completion(.success($0))
            })
            .store(in: &cancelables)
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

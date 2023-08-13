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

    let service = CollectionLoadingService()

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

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {
                guard let data = data, error == nil
                else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(data))
            }
        }

        task.resume()
    }
}

extension CollectionInfo {
    typealias CollectionItem = CollectionPage.CollectionItem
    typealias Image = CollectionPage.CollectionItem.Image

    var collectionItems: [CollectionItem] {
        artObjects.map {
            CollectionItem(
                id: $0.id,
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

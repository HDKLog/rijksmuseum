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

    var imageData: Data?

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {

        let wis = "https://lh3.googleusercontent.com/mZj-trnVh6jeUDsl1o0a3xNXPat_UOZtKecS4LaZdTLcNoIqtd_yf6beJKCUVzk3NT5SSFeQ-hOzJEOOSV9sg8dHE6VjFjUrGfxwe5Sg=s0"
        let webImage = CollectionPage.CollectionItem.Image(width: 10, height: 10, url: URL(string: wis))
        let his = "https://lh3.googleusercontent.com/oY8pcdQahKwdBj_TFoV1UPUFkjY-XQZ5LcPb7Y2Aqexsg5g8h0A6bSWC9qpl-HbS46mX_5C51Du7bRATwQVdMPW0SBE3aDQALUZhCA8=s0"
        let headerImage = CollectionPage.CollectionItem.Image(width: 10, height: 10, url: URL(string: his))
        let item = CollectionPage.CollectionItem(id: "id",
                                                 title: "title",
                                                 description: "some description",
                                                 webImage: webImage,
                                                 headerImage: headerImage)
        let items = Array(repeating: item, count: count)
        let page = CollectionPage(title: "Page \(page)", items: items)

        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            DispatchQueue.main.async {
                completion(.success(page))
            }

        }
    }

    func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {

        if let data = imageData {
            completion(.success(data))
            return
        }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {
                guard let data = data, error == nil
                else {
                    completion(.failure(error!))
                    return
                }

                self.imageData = data
                completion(.success(data))
            }
        }

        task.resume()
    }
}

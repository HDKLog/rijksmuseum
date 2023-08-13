import Foundation


class CollectionLoadingService {
    enum LoadingError: Error {
        case invalidQuery
        case requestError(Error)
        case parsingError(Error)
    }

    typealias CollectionLoadingResult = (Result<CollectionInfo, LoadingError>)
    typealias CollectionLoadingHandler = (CollectionLoadingResult) -> Void

    typealias ImageLoadingResult = (Result<Data, Error>)
    typealias ImageLoadingHandler = (ImageLoadingResult) -> Void

    let session = URLSession.shared

    func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingHandler) {

        let requestUrl = "https://www.rijksmuseum.nl/api/nl/collection"
        var parameters: [String: String] = [:]
        parameters["key"] = "0fiuZFh4"
        parameters["format"] = "json" //json / jsonp / xml
        parameters["culture"] = "en" //nl / en
        parameters["p"] = "\(page)"
        parameters["ps"] = "\(count)"

        let parametersItems = parameters.reduce(into: [String]()) { $0.append("\($1.key)=\($1.value)") }
        let urlString = requestUrl + "?" + parametersItems.joined(separator: "&")

        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidQuery))
            return
        }

        let request = URLRequest(url:url)

        let task = session.dataTask(with: request) { data, response, error in

            error.flatMap { completion(.failure(.requestError($0))) }
            data.flatMap {

                do {
                    let model = try JSONDecoder().decode(CollectionInfo.self, from: $0)
                    completion(.success(model))
                } catch {
                    completion(.failure(.parsingError(error)))
                }
            }
        }

        task.resume()
    }

    func loadImage(url: URL, completion: @escaping ImageLoadingHandler) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil
            else {
                completion(.failure(error!))
                return
            }
            completion(.success(data))
        }

        task.resume()
    }
}


import Foundation

enum ServiceLoadingError: Error {
    case invalidQuery
    case requestError(Error)
    case parsingError(Error)
}

typealias ServiceCollectionLoadingResult = (Result<CollectionInfo, ServiceLoadingError>)
typealias ServiceCollectionLoadingHandler = (ServiceCollectionLoadingResult) -> Void

typealias ServiceImageLoadingResult = (Result<Data, Error>)
typealias ServiceImageLoadingHandler = (ServiceImageLoadingResult) -> Void

protocol ServiceLoading {
    func loadCollection(page: Int, count: Int, completion: @escaping ServiceCollectionLoadingHandler)
    func loadImage(url: URL, completion: @escaping ServiceImageLoadingHandler)

}

class Service: ServiceLoading {

    let session = URLSession.shared

    func loadCollection(page: Int, count: Int, completion: @escaping ServiceCollectionLoadingHandler) {

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

    func loadImage(url: URL, completion: @escaping ServiceImageLoadingHandler) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let task = session.dataTask(with: request) { data, response, error in
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


import Foundation

enum ServiceLoadingError: Error {
    case invalidQuery
    case requestError(Error)
}

typealias ServiceLoadingResult = (Result<Data, ServiceLoadingError>)
typealias ServiceLoadingResultHandler = (ServiceLoadingResult) -> Void

protocol ServiceLoading {
    func getData(query: ServiceQuery, completion: @escaping ServiceLoadingResultHandler)
}

class Service: ServiceLoading {

    let session = URLSession.shared

    func getData(query: ServiceQuery, completion: @escaping ServiceLoadingResultHandler) {
        guard let url = query.getUrl()
        else {
            completion(.failure(.invalidQuery))
            return
        }

        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil
            else {
                completion(.failure(.requestError(error!)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}


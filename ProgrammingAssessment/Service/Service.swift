import Foundation
import Combine

enum ServiceLoadingError: Error {
    case invalidQuery
    case requestError(Error)
}

protocol ServiceLoading {
    func getData(query: ServiceQuery) -> AnyPublisher<Data, ServiceLoadingError>
}

class Service: ServiceLoading {

    let session = URLSession.shared

    var cancelables: [AnyCancellable] = []

    func getData(query: ServiceQuery) -> AnyPublisher<Data, ServiceLoadingError> {

        Just(query.getUrl()).flatMap { [weak self] result -> AnyPublisher<Data, ServiceLoadingError> in
            guard let url = result
            else {
                return Fail<Data, ServiceLoadingError>(error: ServiceLoadingError.invalidQuery)
                    .eraseToAnyPublisher()
            }

            guard let self = self
            else {
                return Empty<Data, ServiceLoadingError>(completeImmediately: true).eraseToAnyPublisher()
            }

            return self.session
                .dataTaskPublisher(for: url)
                .map(\.data)
                .mapError(ServiceLoadingError.requestError)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}


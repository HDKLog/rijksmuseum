//
//  ArtInteractor.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 13.08.23.
//

import Foundation

enum ArtDetailsLoadingError: Error {
    case parsingError(Error)
    case serviceError(ServiceLoadingError)
}

typealias ArtDetailsLoadingResult = Result<ArtDetails, ArtDetailsLoadingError>
typealias ArtDetailsLoadingResultHandler = (ArtDetailsLoadingResult) -> Void

enum ArtDetailsImageLoadingError: Error {
    case serviceError(ServiceLoadingError)
}

typealias ArtDetailsImageLoadingResult = Result<Data, ArtDetailsImageLoadingError>
typealias ArtDetailsImageLoadingResultHandler = (ArtDetailsImageLoadingResult) -> Void

protocol ArtDetailsInteracting {

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler)
    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler)
}

class ArtDetailsInteractor: ArtDetailsInteracting {

    let service: ServiceLoading

    init(service: ServiceLoading) {
        self.service = service
    }

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
        let query = RijksmuseumServiceQuery(request: .collection(artId))

        service.getData(query: query) { result in
            switch result {
            case let .success(data):
                do {
                    let artDetailsInfo = try JSONDecoder().decode(ArtDetailsInfo.self, from: data)
                    let artDetails = artDetailsInfo.artDetails
                    DispatchQueue.main.async {
                        completion(.success( artDetails ))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.parsingError(error)))
                    }
                }
                break
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(.serviceError(error)))
                }
            }
        }
    }

    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
        let query = RijksmuseumImageQuery(url: url.absoluteString)
        service.getData(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    completion(.success( data))
                case let .failure(error):
                    completion(.failure(.serviceError(error)))
                }
            }
        }
    }

}

extension ArtDetailsInfo {
    var artDetails: ArtDetails {
        ArtDetails(id: artObject.id,
                   title: artObject.title,
                   description: artObject.description,
                   webImage: ArtDetails.Image(guid: artObject.webImage.guid,
                                              width: artObject.webImage.width,
                                              height: artObject.webImage.height,
                                              url: URL(string: artObject.webImage.url)))
    }
}

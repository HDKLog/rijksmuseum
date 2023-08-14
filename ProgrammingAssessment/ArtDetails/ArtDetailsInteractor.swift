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

typealias ArtDetailsLoadingResult = Result<String, ArtDetailsLoadingError>
typealias ArtDetailsLoadingResultHandler = (ArtDetailsLoadingResult) -> Void


protocol ArtDetailsInteracting {

    func laodArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler)
}

class ArtDetailsInteractor: ArtDetailsInteracting {

    let service: ServiceLoading

    init(service: ServiceLoading) {
        self.service = service
    }

    func laodArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
        let query = RijksmuseumServiceQuery(request: .collection(artId))

        service.getData(query: query) { result in
            switch result {
            case let .success(data):
                print(String(data: data, encoding: .utf8)!)
            case let .failure(error):
                print(error)
            }
        }
    }

}

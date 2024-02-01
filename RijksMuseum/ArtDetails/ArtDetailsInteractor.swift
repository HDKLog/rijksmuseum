//
//  ArtInteractor.swift
//  RijksMuseum
//
//  Created by Gari Sarkisyan on 13.08.23.
//

import Foundation

enum ArtDetailsError: Error {
    case loading(error: ArtDetailsLoadingError)
}

enum ArtDetailsImageError: Error {
    case loading(error: ArtDetailsImageLoadingError)
}

typealias ArtDetailsResult = Result<ArtDetails, ArtDetailsError>
typealias ArtDetailsResultHandler = (ArtDetailsResult) -> Void

typealias ArtDetailsImageResult = Result<Data, ArtDetailsImageError>
typealias ArtDetailsImageResultHandler = (ArtDetailsImageResult) -> Void

protocol ArtDetailsInteracting {
    func loadArtDetails(artId: String, completion: @escaping ArtDetailsResultHandler)
    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageResultHandler)
}

class ArtDetailsInteractor: ArtDetailsInteracting {

    let gateway: ArtGateway

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsResultHandler) {
        gateway.loadArtDetails(artId: artId) { result in
            switch result {
            case let .success(info):
                let details = info.artDetails
                completion(.success(details))
            case let .failure(error):
                completion(.failure(.loading(error: error)))
            }
        }
    }

    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageResultHandler) {
        gateway.loadArtDetailsImageData(from: url) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.loading(error: error)))
            }
        }
    }

}

extension ArtDetailsInfo {
    var artDetails: ArtDetails {
        ArtDetails(id: artObject.id,
                   title: artObject.title,
                   description: artObject.description,
                   webImage: artObject.webImage?.artImage)
    }
}

extension ArtDetailsInfo.Art.ImageInfo {
    typealias Image = ArtDetails.Image
    var artImage: Image {
        Image(guid: guid,
              width: width,
              height: height,
              url: URL(string: url))
    }
}

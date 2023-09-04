//
//  ArtInteractor.swift
//  RijksMuseum
//
//  Created by Gari Sarkisyan on 13.08.23.
//

import Foundation
import Combine

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

    var cancelables: [AnyCancellable] = []

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsResultHandler) {
        gateway.loadArtDetails(artId: artId)
            .receive(on: DispatchQueue.main)
            .mapError(ArtDetailsError.loading)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    completion(.failure(error))
                }
            }, receiveValue: {
                completion(.success($0.artDetails))
            })
            .store(in: &cancelables)
    }

    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageResultHandler) {
        gateway.loadArtDetailsImageData(from: url)
            .receive(on: DispatchQueue.main)
            .mapError(ArtDetailsImageError.loading)
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

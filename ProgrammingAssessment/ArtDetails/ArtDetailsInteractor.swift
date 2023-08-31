//
//  ArtInteractor.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 13.08.23.
//

import Foundation

protocol ArtDetailsInteracting {
    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler)
    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler)
}

class ArtDetailsInteractor: ArtDetailsInteracting {

    let gateway: ArtGateway

    init(gateway: ArtGateway) {
        self.gateway = gateway
    }

    func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
        gateway.loadArtDetails(artId: artId, completion: completion)
    }

    func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
        gateway.loadArtDetailsImageData(from: url, completion: completion)
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

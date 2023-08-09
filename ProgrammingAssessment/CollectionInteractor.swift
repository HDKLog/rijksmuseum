//
//  CollectionInteractor.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import Foundation

typealias CollectionLoadingResul = Result<[CollectionItem], Error>
typealias CollectionLoadingResultHandler = (CollectionLoadingResul) -> Void

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResultHandler)
}

class CollectionInteractor: CollectionInteracting {

    func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResultHandler) {

    }
}

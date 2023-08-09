//
//  CollectionInteractor.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import Foundation

typealias CollectionLoadingResult = (Result<[CollectionItem], Error>) -> Void

protocol CollectionInteracting {
    func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResult)
}

class CollectionInteractor: CollectionInteracting {

    func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResult) { }
}

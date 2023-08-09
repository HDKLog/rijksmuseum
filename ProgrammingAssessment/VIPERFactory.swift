//
//  VIPERFactory.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import Foundation

protocol VIPERFactory {
    func createCollection() -> CollectionViewController
}

extension AppDelegate: VIPERFactory {

    func createCollection() -> CollectionViewController {
        let collectionView = CollectionViewController()
        let collectionInteractor = CollectionInteractor()
        let collectionPresenter = CollectionPresenter(view: collectionView, interactor: collectionInteractor)
        let collectionRouter = CollectionRouter(rootViewController: collectionView)
        collectionPresenter.router = collectionRouter
        collectionView.presenter = collectionPresenter

        return collectionView
    }
}

import UIKit

protocol VIPERFactory {
    func createCollection() -> UIViewController
}

extension AppDelegate: VIPERFactory {

    func createCollection() -> UIViewController {
        let collectionView = CollectionViewController()
        let collectionInteractor = CollectionInteractor()
        let collectionPresenter = CollectionPresenter(view: collectionView, interactor: collectionInteractor)
        let collectionRouter = CollectionRouter(rootViewController: collectionView)
        collectionPresenter.router = collectionRouter
        collectionView.presenter = collectionPresenter

        return collectionRouter
    }
}

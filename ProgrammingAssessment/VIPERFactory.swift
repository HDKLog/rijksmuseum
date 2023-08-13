import UIKit

protocol VIPERFactory {
    func createCollection(artDetailViewController: ArtDetailsViewController) -> CollectionViewController
    func createArtDetails() -> ArtDetailsViewController
}

extension AppDelegate: VIPERFactory {

    func createCollection(artDetailViewController: ArtDetailsViewController) -> CollectionViewController {
        let view = CollectionViewController()
        let interactor = CollectionInteractor()
        let presenter = CollectionPresenter(view: view, interactor: interactor)
        let router = CollectionRouter(collectionViewController: view, artDetailsViewController: artDetailViewController)
        presenter.router = router
        view.presenter = presenter

        return view
    }

    func createArtDetails() -> ArtDetailsViewController {
        let view = ArtDetailsViewController()
        let interactor = ArtDetailsInteractor()
        let presenter = ArtDetailsPresenter(view: view, interactor: interactor)
        let router = ArtDetailsRouter(artDetailsViewController: view)
        presenter.router = router
        view.presenter = presenter

        return view
    }
}

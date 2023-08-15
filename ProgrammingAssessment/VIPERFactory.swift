import UIKit

protocol VIPERFactory {
    func createCollection(endView: UIViewController ,routingEndpoint: CollectionRoutingEndpoint) -> CollectionViewController
    func createArtDetails() -> ArtDetailsViewController
}

extension AppDelegate: VIPERFactory {

    func createCollection(endView: UIViewController ,routingEndpoint: CollectionRoutingEndpoint) -> CollectionViewController {
        let view = CollectionViewController()
        let service = Service()
        let interactor = CollectionInteractor(service: service)
        let presenter = CollectionPresenter(view: view, interactor: interactor)
        let router = CollectionRouter(rootView: view, endView: endView, endpoint: routingEndpoint)
        presenter.router = router
        view.presenter = presenter

        return view
    }

    func createArtDetails() -> ArtDetailsViewController {
        let view = ArtDetailsViewController()
        let service = Service()
        let interactor = ArtDetailsInteractor(service: service)
        let presenter = ArtDetailsPresenter(view: view, interactor: interactor)
        let router = ArtDetailsRouter(artDetailsViewController: view)
        presenter.router = router
        view.presenter = presenter

        return view
    }
}

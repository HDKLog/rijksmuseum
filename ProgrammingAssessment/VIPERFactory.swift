import UIKit

protocol VIPERFactory {
    func createCollection(endView: UIViewController ,routingEndpoint: CollectionRoutingEndpoint) -> CollectionViewController
    func createArtDetails() -> ArtDetailsViewController
}

extension AppDelegate: VIPERFactory {

    private var service: ServiceLoading { Service() }
    private var gateway: ArtGateway { RijksmuseumArtGateway(service: service) }

    func createCollection(endView: UIViewController ,routingEndpoint: CollectionRoutingEndpoint) -> CollectionViewController {
        let interactor = CollectionInteractor(gateway: gateway)
        let view = CollectionViewController()
        let presenter = CollectionPresenter(view: view, interactor: interactor)
        let router = CollectionRouter(rootView: view, endView: endView, endpoint: routingEndpoint)
        presenter.router = router
        view.presenter = presenter

        return view
    }

    func createArtDetails() -> ArtDetailsViewController {
        let interactor = ArtDetailsInteractor(gateway: gateway)
        let view = ArtDetailsViewController()
        let presenter = ArtDetailsPresenter(view: view, interactor: interactor)
        let router = ArtDetailsRouter(artDetailsViewController: view)
        presenter.router = router
        view.presenter = presenter

        return view
    }
}

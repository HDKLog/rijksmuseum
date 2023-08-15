import UIKit

protocol CollectionRouting {
    func routeToArtDetail(ardId: String)
}

protocol CollectionRoutingEndpoint {
    func loadArtDetail(ardId: String)
}

class CollectionRouter: CollectionRouting {

    let rootView: UIViewController!
    let endView: UIViewController!
    let endpoint: CollectionRoutingEndpoint!

    init(rootView: UIViewController, endView: UIViewController, endpoint: CollectionRoutingEndpoint) {
        self.rootView = rootView
        self.endView = endView
        self.endpoint = endpoint
    }

    func routeToArtDetail(ardId: String) {
        rootView.navigationController?.pushViewController(endView, animated: true)
        endpoint.loadArtDetail(ardId: ardId)
    }

}

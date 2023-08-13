import UIKit

enum CollectionRoutingPath {
    case collection
    case itemDetails
}

protocol CollectionRouting {
    func root(to: CollectionRoutingPath)
    func rootBack()
}

class CollectionRouter: UINavigationController, CollectionRouting {

    func root(to: CollectionRoutingPath) {

    }

    func rootBack() {
        
    }
}

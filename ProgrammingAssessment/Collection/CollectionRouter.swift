import UIKit

protocol CollectionRoutingDestination {}

protocol CollectionRouting {
    func routeToArtDetail(ardId: String)
}

class CollectionRouter: CollectionRouting {

    let collectionViewController: CollectionViewController!
    let artDetailsViewController: ArtDetailsViewController!

    init(collectionViewController: CollectionViewController, artDetailsViewController: ArtDetailsViewController) {
        self.collectionViewController = collectionViewController
        self.artDetailsViewController = artDetailsViewController
    }

    func routeToArtDetail(ardId: String) {
        collectionViewController.navigationController?.pushViewController(artDetailsViewController, animated: true)
        artDetailsViewController.presenter?.loadArt(artId: ardId)
    }

}

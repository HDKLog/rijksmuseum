import UIKit

protocol ArtDetailsRouting {

    func routeToCollection()
}

class ArtDetailsRouter: ArtDetailsRouting {

    let artDetailsViewController: ArtDetailsViewController!

    init(artDetailsViewController: ArtDetailsViewController) {
        self.artDetailsViewController = artDetailsViewController
    }

    func routeToCollection() {
        artDetailsViewController.navigationController?.popViewController(animated: true)
    }

}

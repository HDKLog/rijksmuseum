import UIKit

protocol ArtDetailsView {

}

class ArtDetailsViewController: UIViewController, ArtDetailsView {
    var presenter: ArtDetailsPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

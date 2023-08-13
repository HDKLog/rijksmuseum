import UIKit

protocol ArtDetailsView {

}

class ArtDetailsViewController: UIViewController, ArtDetailsView {
    var presenter: ArtDetailsPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DesignBook.Color.Background.main.uiColor()
    }
}

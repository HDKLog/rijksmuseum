import UIKit

protocol ArtDetailsView {
    func configure()
}

class ArtDetailsViewController: UIViewController, ArtDetailsView {
    var presenter: ArtDetailsPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadView()
    }

    private func setup() {
        view.backgroundColor = DesignBook.Color.Background.main.uiColor()
    }

    func configure() {
        
    }
}

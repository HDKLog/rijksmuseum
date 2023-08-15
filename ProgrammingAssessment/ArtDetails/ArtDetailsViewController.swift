import UIKit
import SkeletonView

protocol ArtDetailsView {
    func configure(with model: ArtDetailsViewModel.InitialInfo)
    func updateDetails(with model: ArtDetailsViewModel.ArtDetails)
    func updateImage(with data: Data)
    func displayError(error: Error)
}

class ArtDetailsViewController: UIViewController, ArtDetailsView {
    var presenter: ArtDetailsPresenting?

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isSkeletonable = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.showAnimatedGradientSkeleton()
    }

    private func setup() {
        view.backgroundColor = DesignBook.Color.Background.main.uiColor()
        setupImageView()
    }

    private func setupImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
    }

    func configure(with model: ArtDetailsViewModel.InitialInfo) {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: model.backButtonTitle,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backToCollection))

    }

    func updateDetails(with model: ArtDetailsViewModel.ArtDetails) {
        
    }

    func updateImage(with data: Data) {
        imageView.image = UIImage(data: data)
        imageView.hideSkeleton()
    }

    func displayError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    @objc
    func backToCollection(sender: AnyObject) {
        presenter?.routBack()
    }
}

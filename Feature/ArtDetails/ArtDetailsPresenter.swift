import Foundation

protocol ArtDetailsPresenting {
    func loadView()
    func loadArt()
    func routBack()
}

class ArtDetailsPresenter: ArtDetailsPresenting {
    let view: ArtDetailsView!
    let interactor: ArtDetailsInteracting!
    var router: ArtDetailsRouting?
    let artId: String

    init(view: ArtDetailsView, interactor: ArtDetailsInteracting, artId: String) {
        self.view = view
        self.interactor = interactor
        self.artId = artId
    }

    func loadView() {
        view.configure(with: ArtDetailsViewModel.InitialInfo(backButtonTitle: "◀︎ Collection"))
        loadArt()
    }

    func loadArt() {
        interactor.loadArtDetails(artId: artId) { [weak self] result in
            switch result {
            case let .success(artDetails):
                self?.view.updateDetails(with: artDetails.artDetailsViewModel)
                self?.loadImage(url: artDetails.webImage?.url)
            case let .failure(error):
                self?.view.displayError(error: error)
            }
        }
    }

    func routBack() {
        router?.routeToCollection()
    }

    private func loadImage(url: URL?) {
        guard let url = url else { return }
        interactor.loadArtDetailsImageData(from: url) {[weak self] result in
            switch result {
            case let .success(data):
                self?.view.updateImage(with: data)
            case let .failure(error):
                self?.view.displayError(error: error)
            }
        }
    }
}

extension ArtDetails {
    var artDetailsViewModel: ArtDetailsViewModel.ArtDetails {
        ArtDetailsViewModel.ArtDetails(title: title, description: description)
    }
}

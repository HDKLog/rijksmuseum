import Foundation

protocol ArtDetailsPresenting {

    func loadView()
    func loadArt(artId: String)

}

class ArtDetailsPresenter: ArtDetailsPresenting {
    let view: ArtDetailsView!
    let interactor: ArtDetailsInteracting!
    var router: ArtDetailsRouting?

    init(view: ArtDetailsView, interactor: ArtDetailsInteracting) {
        self.view = view
        self.interactor = interactor
    }

    func loadView() {
        view.configure(with: ArtDetailsViewModel.InitialInfo(backButtonTitle: "Collection"))
    }

    func loadArt(artId: String) {
        interactor.laodArtDetails(artId: artId) { result in
            switch result {
            case let .success(artDetails):
                let model = ArtDetailsViewModel.ArtDetails(title: artDetails.title)
                self.view.updateDetails(with: model)
            case let .failure(error):
                print(error)
            }
        }
    }
}

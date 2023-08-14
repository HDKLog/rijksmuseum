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
        view.configure()
    }

    func loadArt(artId: String) {
        interactor.laodArtDetails(artId: artId) { _ in }
    }
}

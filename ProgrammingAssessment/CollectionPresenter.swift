import Foundation

protocol CollectionPresenting {
    func loadCollection()
}

class CollectionPresenter: CollectionPresenting {

    let view: CollectionView!
    let interactor: CollectionInteracting!
    var router: CollectionRouting?

    init(view: CollectionView, interactor: CollectionInteracting) {
        self.view = view
        self.interactor = interactor
    }

    func loadCollection() { }

}

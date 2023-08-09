import Foundation

protocol CollectionPresenting {
    func loadCollection()
}

class CollectionPresenter: CollectionPresenting {

    let view: CollectionView!
    let interactor: CollectionInteracting!
    var router: CollectionRouting?

    var currentPage: Int = 0
    let resultsOnPage: Int = 10

    var collectionItems: [CollectionItem] = []

    init(view: CollectionView, interactor: CollectionInteracting) {
        self.view = view
        self.interactor = interactor
    }

    func loadCollection() {
        loadNext()
    }

    private func loadNext() {
        interactor.loadCollection(page: currentPage, count: resultsOnPage) { [weak self] result in
            switch result {
            case let .success(collection):
                self?.collectionItems.append(contentsOf: collection)
                self?.currentPage += 1
            case let .failure(error):
                print(error)
            }
        }
    }

}

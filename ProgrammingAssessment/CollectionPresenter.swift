import Foundation

protocol CollectionPresenting {
    func loadCollection()

    func numberOfPages() -> Int
    func numberOfItems(on page: Int) -> Int

    func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void)
    func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void)

    func loadNextPage()
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
        view.configure(with: CollectionViewModel(title: "Collection"))
        loadNextPage()
    }

    func numberOfPages() -> Int {
        0
    }

    func numberOfItems(on page: Int) -> Int {
        0
    }

    func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void) {

    }

    func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void) {
        
    }

    func loadNextPage() {
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

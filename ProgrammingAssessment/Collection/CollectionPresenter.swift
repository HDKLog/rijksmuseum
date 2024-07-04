import Foundation

protocol CollectionPresenting {
    func loadCollection()

    func numberOfPages() -> Int
    func numberOfItems(on page: Int) -> Int
    
    func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void)
    func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void)
    func chooseItem( itemIndex: Int, on page: Int)

    func loadNextPage()
}

class CollectionPresenter: CollectionPresenting {

    let view: CollectionView!
    let interactor: CollectionInteracting!
    var router: CollectionRouting?

    var currentPage: Int = 1
    let resultsOnPage: Int = 10

    var collectionPages: [CollectionPage] = []

    init(view: CollectionView, interactor: CollectionInteracting) {
        self.view = view
        self.interactor = interactor
    }

    func loadCollection() {

        view.configure(with: CollectionViewModel(title: "Collection", animatingLoad: true, firstScreenText: "Loading"))
        interactor.loadCollection(page: currentPage, count: resultsOnPage) { [weak self] result in
            switch result {
            case let .success(pageinfo):
                self?.view.configure(with: CollectionViewModel(title: "Collection", animatingLoad: false, firstScreenText: nil))
                self?.collectionPages.append(pageinfo)
                self?.view.updateCollection()
                self?.currentPage += 1
            case let .failure(error):
                self?.view.configure(with: CollectionViewModel(title: "Collection", animatingLoad: false, firstScreenText: "Error"))
                self?.view.displayError(error: error)
            }
        }
    }

    func numberOfPages() -> Int {
        collectionPages.count
    }

    func numberOfItems(on page: Int) -> Int {
        collectionPages[page].items.count
    }

    func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void) {
        
        let item = collectionPages[page].items[index]
        guard let url = item.webImage.url
        else {
            completion(CollectionViewCellModel(imageData: Data(), title: item.title))
            return
        }
        
        interactor.loadCollectionItemImageData(from: url, scale: .thumbnail) { result in
            switch result {
            case let .success(data):
                completion(CollectionViewCellModel(imageData: data, title: item.title))
            case let .failure(error):
                print(error)
            }
        }
    }

    func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void) {
        completion(CollectionViewHeaderModel(title: collectionPages[page].title))
    }

    func chooseItem(itemIndex: Int, on page: Int) {
        let item = collectionPages[page].items[itemIndex]
        router?.routeToArtDetail(ardId: item.id)
    }

    func loadNextPage() {
        interactor.loadCollection(page: currentPage, count: resultsOnPage) { [weak self] result in
            switch result {
            case let .success(pageinfo):
                self?.collectionPages.append(pageinfo)
                self?.view.updateCollection()
                self?.currentPage += 1
            case let .failure(error):
                self?.view.displayError(error: error)
            }
        }
    }

}
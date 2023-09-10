import Foundation
import Combine

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
    let resultsOnPage: Int = 30

    var collectionPages: [CollectionPage] = []

    var cancellables: [AnyCancellable] = []

    init(view: CollectionView, interactor: CollectionInteracting) {
        self.view = view
        self.interactor = interactor
    }

    func loadCollection() {
        view.configure(with: .loadingModel)
        interactor.loadCollection(page: currentPage, count: resultsOnPage)
            .catch { [weak self] error in
                self?.view.configure(with: .loadFailModel)
                self?.view.displayError(error: error)
                return Empty<CollectionPage, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { [weak self] page in
                self?.view.configure(with: .loadSuccessModel)
                self?.updateNext(page: page)
            }
            .store(in: &cancellables)
    }

    func numberOfPages() -> Int {
        collectionPages.count
    }

    func numberOfItems(on page: Int) -> Int {
        collectionPages[page].items.count
    }

    func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void) {
        
        let item = collectionPages[page].items[index]
        guard let url = item.webImage?.url
        else {
            completion(CollectionViewCellModel(imageData: Data(), title: item.title))
            return
        }
        
        interactor.loadCollectionItemImageData(from: url)
            .catch { [weak self] error in
                self?.view.displayError(error: error)
                self?.itemModel(on: page, at: index, completion: completion)
                return Empty<Data, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .flatMap {
                completion(CollectionViewCellModel(imageData: $0, title: item.title))
                return Empty<Data, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
    }

    func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void) {
        completion(CollectionViewHeaderModel(title: collectionPages[page].title))
    }

    func chooseItem(itemIndex: Int, on page: Int) {
        let item = collectionPages[page].items[itemIndex]
        router?.routeToArtDetail(ardId: item.id)
    }

    func loadNextPage() {
        interactor.loadCollection(page: currentPage, count: resultsOnPage)
            .catch { [weak self] error in
                self?.view.displayError(error: error)
                self?.loadNextPage()
                return Empty<CollectionPage, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .flatMap { [weak self] page in
                self?.updateNext(page: page)
                return Empty<CollectionPage, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
    }

    func reload() {
        loadCollection()
    }

    private func updateNext(page: CollectionPage) {
        collectionPages.append(page)
        view.updateCollection()
        currentPage += 1
    }
}

extension CollectionViewModel {
    static var loadingModel: CollectionViewModel {
        CollectionViewModel(title: "Collection", animatingLoad: true, firstScreenText: "Loading")
    }

    static var loadSuccessModel: CollectionViewModel {
        CollectionViewModel(title: "Collection", animatingLoad: false, firstScreenText: nil)
    }

    static var loadFailModel: CollectionViewModel {
        CollectionViewModel(title: "Collection", animatingLoad: false, firstScreenText: "Fail to load. Tap to retry")
    }
}

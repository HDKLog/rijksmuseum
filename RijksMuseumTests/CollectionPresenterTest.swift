import XCTest

@testable import RijksMuseum
final class CollectionPresenterTest: XCTestCase {

    class View: CollectionView {

        var configureCalled: Bool { configureCalls > 0 }
        var configureCalls: Int = 0
        var configureClosure: (CollectionViewModel) -> Void = {_ in }
        func configure(with model: CollectionViewModel) {
            configureCalls += 1
            configureClosure(model)
        }

        var updateCollectionCalled: Bool { updateCollectionCalls > 0 }
        var updateCollectionCalls: Int = 0
        var updateCollectionClosure: () -> Void = { }
        func updateCollection() {
            updateCollectionCalls += 1
            updateCollectionClosure()
        }

        var displayErrorCalled: Bool { displayErrorCalls > 0 }
        var displayErrorCalls: Int = 0
        var displayErrorClosure: (Error) -> Void = {_ in }
        func displayError(error: Error) {
            displayErrorCalls += 1
            displayErrorClosure(error)
        }
    }

    class Interactor: CollectionInteracting {


        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionClosure: (Int, Int, @escaping CollectionResultHandler) -> Void = { _, _, _ in }
        func loadCollection(page: Int, count: Int, completion: @escaping CollectionResultHandler){
            loadCollectionCalls += 1
            loadCollectionClosure(page, count, completion)
        }

        var loadCollectionItemImageDataCalled: Bool { loadCollectionItemImageDataCalls > 0 }
        var loadCollectionItemImageDataCalls: Int = 0
        var loadCollectionItemImageDataClosure: (URL, @escaping CollectionImageDataResultHandler) -> Void = { _, _ in }
        func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageDataResultHandler) {
            loadCollectionItemImageDataCalls += 1
            loadCollectionItemImageDataClosure(url, completion)
        }
    }

    class Router: CollectionRouting {

        var routeToArtDetailCalled: Bool { routeToArtDetailCalls > 0 }
        var routeToArtDetailCalls: Int = 0
        var routeToArtDetailClosure: (String) -> Void = {_ in }
        func routeToArtDetail(ardId: String) {
            routeToArtDetailCalls += 1
            routeToArtDetailClosure(ardId)
        }
    }

    func makeSut(view: CollectionView, interactor: CollectionInteracting, router: CollectionRouting? = nil) -> CollectionPresenter {
        let presenter = CollectionPresenter(view: view, interactor: interactor)
        presenter.router = router
        return presenter
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadCollection() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(interactor.loadCollectionCalled)
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadCollectionOnce() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(interactor.loadCollectionCalls, 1)
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadFirstPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, _ in loadedPage = page}
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(loadedPage, 1)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingSuccessIncreaseCurrentPageOnce() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            loadedPage = page
            completion(.success(.mocked))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.currentPage, loadedPage! + 1)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingSuccessTellsViewToUpdateCollectionOnce() {
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(view.updateCollectionCalls, 1)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingSuccessConfiguresViewToDisplaySuccess() {
        let view = View()
        let interactor = Interactor()
        var viewModel: CollectionViewModel?
        interactor.loadCollectionClosure = { _, _, completion in
            viewModel = nil
            completion(.success(.mocked))
        }

        view.configureClosure = { model in
            viewModel = model
        }

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertNotNil(viewModel)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingFailureDoNotIncreaseCurrentPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            loadedPage = page
            completion(.failure(.loading(error:.serviceError(.invalidQuery))))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.currentPage, loadedPage)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingFailureConfiguresViewToDisplayFailure() {
        let view = View()
        let interactor = Interactor()
        var viewModel: CollectionViewModel?
        interactor.loadCollectionClosure = { _, _, completion in
            viewModel = nil
            completion(.failure(.loading(error: .serviceError(.invalidQuery))))
        }

        view.configureClosure = { model in
            viewModel = model
        }

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertNotNil(viewModel)
    }

    func test_collectionPresenter_onLoadCollection_onLoadingFailureTellsViewToDisplayError() {
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.failure(.loading(error: .serviceError(.invalidQuery))))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(view.displayErrorCalled)
    }

    func test_collectionPresenter_onLoadNextPage_tellsInteractorToLoadNextPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            loadedPage = page
            completion(.success(CollectionPage(title: "", items: [])))
        }
        let sut = makeSut(view: view, interactor: interactor)

        let firstPage = sut.currentPage
        sut.loadNextPage()

        XCTAssertEqual(loadedPage, firstPage)
    }

    func test_collectionPresenter_onLoadNextPage_onLoadingSuccessIncreaseCurrentPageOnce() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            loadedPage = page
            completion(.success(.mocked))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        XCTAssertEqual(sut.currentPage, loadedPage! + 1)
    }

    func test_collectionPresenter_onLoadNextPage_onLoadingFailureDoNotIncreaseCurrentPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            if loadedPage == nil {
                loadedPage = page
                completion(.failure(.loading(error: .serviceError(.invalidQuery))))
                return
            }
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        XCTAssertEqual(sut.currentPage, loadedPage)
    }

    func test_collectionPresenter_onLoadNextPage_onLoadingFailureTellsViewToDisplayError() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            if loadedPage == nil {
                loadedPage = page
                completion(.failure(.loading(error: .serviceError(.invalidQuery))))
            }
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        XCTAssertTrue(view.displayErrorCalled)
    }

    func test_collectionPresenter_onLoadNextPage_onLoadingFailureRetryToLoadNextPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            if loadedPage == nil {
                loadedPage = page
                completion(.failure(.loading(error: .serviceError(.invalidQuery))))
            }
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        XCTAssertEqual(interactor.loadCollectionCalls, 2)
    }

    func test_collectionPresenter_onLoadCollection_configureView() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(view.configureCalled)
    }

    func test_collectionPresenter_onNumberOfPages_returnsNumberOfPages() {
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.numberOfPages(), 1)
    }

    func test_collectionPresenter_onNumberOfItems_returnsNumberOfItemsPages() {
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.numberOfItems(on: 0), CollectionPage.mocked.items.count)
    }

    func test_collectionPresenter_onItemModel_onSuccessReturnsItemModel() {
        let view = View()
        let interactor = Interactor()
        let mockedResult: CollectionPage = .mocked
        var loadedModel: CollectionViewCellModel?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(mockedResult))
        }
        interactor.loadCollectionItemImageDataClosure = { url, complition in
            complition(.success(Data()))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.itemModel(on: 0, at: 0) { model in
            loadedModel = model
        }

        XCTAssertEqual(loadedModel, CollectionViewCellModel(imageData: Data(), title: mockedResult.items[0].title))
    }

    func test_collectionPresenter_onItemModel_onFailureTellsViewToDisplayError() {
        let view = View()
        let interactor = Interactor()
        var loadingUrl: URL?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        interactor.loadCollectionItemImageDataClosure = { url, complition in
            if loadingUrl == nil {
                loadingUrl = url
                complition(.failure(.loading(error: .serviceError(.invalidQuery))))
            }
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.itemModel(on: 0, at: 0) { _ in }

        XCTAssertTrue(view.displayErrorCalled)
    }

    func test_collectionPresenter_onItemModel_onFailureRetryToLoadItemModel() {
        let view = View()
        let interactor = Interactor()
        var loadingUrl: URL?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        interactor.loadCollectionItemImageDataClosure = { url, complition in
            if loadingUrl == nil {
                loadingUrl = url
                complition(.failure(.loading(error: .serviceError(.invalidQuery))))
            }
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.itemModel(on: 0, at: 0) { _ in }

        XCTAssertEqual(interactor.loadCollectionItemImageDataCalls, 2)
    }

    func test_collectionPresenter_onHeaderModel_returnsHeaderModel() {
        let view = View()
        let interactor = Interactor()
        var loadedModel: CollectionViewHeaderModel?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }
        interactor.loadCollectionItemImageDataClosure = { url, complition in
            complition(.success(Data()))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.headerModel(on: 0) { model in
            loadedModel = model
        }

        XCTAssertEqual(loadedModel, .mocked)
    }

    func test_onChooseItem_routToItem() {
        let view = View()
        let interactor = Interactor()
        let router = Router()
        let sut = makeSut(view: view, interactor: interactor, router: router)

        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }

        sut.loadCollection()

        sut.chooseItem(itemIndex: 0, on: 0)

        XCTAssertTrue(router.routeToArtDetailCalled)
    }

    func test_onChooseItem_routToItemWithItemId() {
        var routingItemId: String?
        let view = View()
        let interactor = Interactor()
        let router = Router()
        let sut = makeSut(view: view, interactor: interactor, router: router)

        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked))
        }

        router.routeToArtDetailClosure = { id in
            routingItemId = id
        }

        sut.loadCollection()

        sut.chooseItem(itemIndex: 0, on: 0)

        XCTAssertEqual(routingItemId, sut.collectionPages[0].items[0].id)
    }
}

extension CollectionPage {
    static var mocked: CollectionPage {
        let image = CollectionPage.CollectionItem.Image(
            guid: "bbd1fae8-4023-4859-8ed1-d38616aec96c",
            width: 5656,
            height: 4704,
            url: URL(string: "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"))
        let item = CollectionPage.CollectionItem(
            id: "SK-C-5",
            title: "The Night Watch",
            description: "The Night Watch, Rembrandt van Rijn, 1642",
            webImage: image,
            headerImage: image
            )
        let items = Array(repeating: item, count: 3)
        return CollectionPage(title: "Page 0", items: items)
    }
}

extension CollectionViewCellModel: Equatable {
    public static func == (lhs: CollectionViewCellModel, rhs: CollectionViewCellModel) -> Bool {
        lhs.title == rhs.title && lhs.imageData == rhs.imageData
    }
}

extension CollectionViewHeaderModel: Equatable {
    public static func == (lhs: CollectionViewHeaderModel, rhs: CollectionViewHeaderModel) -> Bool {
        lhs.title == rhs.title
    }
}

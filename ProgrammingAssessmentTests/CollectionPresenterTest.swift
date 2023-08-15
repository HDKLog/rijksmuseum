import XCTest

@testable import ProgrammingAssessment
final class CollectionPresenterTest: XCTestCase {

    class View: CollectionView {

        var configureCalled: Bool { configureCalls > 0 }
        var configureCalls: Int = 0
        var configureClosure: (CollectionViewModel) -> Void = {_ in }
        func configure(with model: CollectionViewModel) {
            configureCalls += 1
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
        var loadCollectionClosure: (Int, Int, @escaping CollectionLoadingResultHandler) -> Void = { _, _, _ in }
        func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler){
            loadCollectionCalls += 1
            loadCollectionClosure(page, count, completion)
        }

        var loadCollectionItemImageDataCalled: Bool { loadCollectionItemImageDataCalls > 0 }
        var loadCollectionItemImageDataCalls: Int = 0
        var loadCollectionItemImageDataClosure: (URL, CollectionImageLoadingScale, @escaping CollectionImageLoadingResultHandler) -> Void = { _, _, _ in }
        func loadCollectionItemImageData(from url: URL,
                                         scale: ProgrammingAssessment.CollectionImageLoadingScale,
                                         completion: @escaping CollectionImageLoadingResultHandler) {
            loadCollectionItemImageDataCalls += 1
            loadCollectionItemImageDataClosure(url, scale, completion)
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

    func test_collectionPresenter_onloadNextPage_tellsInteractorToLoadNextPage() {
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, completion in
            loadedPage = page
            completion(.success(CollectionPage(title: "", items: [])))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()
        sut.loadNextPage()

        XCTAssertEqual(loadedPage, 2)
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
            completion(.success(.mocked(itemsCount: 1)))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.numberOfPages(), 1)
    }

    func test_collectionPresenter_onNumberOfItems_returnsNumberOfItemsPages() {
        let view = View()
        let interactor = Interactor()
        let numberOfItems = 3
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked(itemsCount: numberOfItems)))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(sut.numberOfItems(on: 0), numberOfItems)
    }

    func test_collectionPresenter_onItemModel_returnsItemModel() {
        let view = View()
        let interactor = Interactor()
        let numberOfItems = 3
        let mockedResult: CollectionPage = .mocked(itemsCount: numberOfItems)
        var loadedModel: CollectionViewCellModel?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(mockedResult))
        }
        interactor.loadCollectionItemImageDataClosure = { url, scale, complition in
            complition(.success(Data()))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.itemModel(on: 0, at: 0) { model in
            loadedModel = model
        }

        XCTAssertEqual(loadedModel, CollectionViewCellModel(imageData: Data(), title: mockedResult.items[0].title))
    }

    func test_collectionPresenter_onHeaderModel_returnsHeaderModel() {
        let view = View()
        let interactor = Interactor()
        let numberOfItems = 3
        var loadedModel: CollectionViewHeaderModel?
        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked(itemsCount: numberOfItems)))
        }
        interactor.loadCollectionItemImageDataClosure = { url, scale, complition in
            complition(.success(Data()))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadNextPage()

        sut.headerModel(on: 0) { model in
            loadedModel = model
        }

        XCTAssertEqual(loadedModel, CollectionViewHeaderModel(title: "Page 1"))
    }

    func test_collectionPresenter_onLoadCollectionError_presentErrorInView() {
        let error: Error = NSError(domain: "", code: 0)
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = {_, _, completion in
            completion(.failure(.serviceError(.requestError(error))))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(view.displayErrorCalled)
    }

    func test_onChooseItem_routToItem() {
        let numberOfItems = 3
        let view = View()
        let interactor = Interactor()
        let router = Router()
        let sut = makeSut(view: view, interactor: interactor, router: router)

        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked(itemsCount: numberOfItems)))
        }

        sut.loadCollection()

        sut.chooseItem(itemIndex: 0, on: 0)

        XCTAssertTrue(router.routeToArtDetailCalled)
    }

    func test_onChooseItem_routToItemWithItemId() {
        let numberOfItems = 3
        var routingItemId: String?
        let view = View()
        let interactor = Interactor()
        let router = Router()
        let sut = makeSut(view: view, interactor: interactor, router: router)

        interactor.loadCollectionClosure = { _, _, completion in
            completion(.success(.mocked(itemsCount: numberOfItems)))
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
    static func mocked(itemsCount: Int) -> CollectionPage {
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
        let items = Array(repeating: item, count: itemsCount)
        return CollectionPage(title: "Page 1", items: items)
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

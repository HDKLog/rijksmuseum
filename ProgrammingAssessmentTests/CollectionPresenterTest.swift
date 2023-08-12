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
        var loadCollectionItemImageClosure: (URL, @escaping CollectionImageLoadingResultHandler) -> Void = { _, _ in }
        func loadCollectionItemImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {
            loadCollectionItemImageDataCalls += 1
            loadCollectionItemImageClosure(url, completion)
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

    func test_collectionPresenter_onLoadCollectionError_presentErrorInView() {
        let error: Error = NSError(domain: "", code: 0)
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = {_, _, completion in
            completion(.failure(error))
        }
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(view.displayErrorCalled)
    }
}

import XCTest

@testable import ProgrammingAssessment
final class CollectionViewControllerTest: XCTestCase {

    class Presenter: CollectionPresenting {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        func loadCollection() {
            loadCollectionCalls += 1
        }


        var numberOfPagesCalled: Bool { numberOfPagesCalls > 0 }
        var numberOfPagesCalls: Int = 0
        var numberOfPagesClosure: () -> Int = { 1 }
        func numberOfPages() -> Int {
            numberOfPagesCalls += 1
            return numberOfPagesClosure()
        }

        var numberOfItemsCalled: Bool { numberOfItemsCalls > 0 }
        var numberOfItemsCalls: Int = 0
        var numberOfItemsClosure: (Int) -> Int = { _ in 0 }
        func numberOfItems(on page: Int) -> Int {
            numberOfItemsCalls += 1
            return numberOfItemsClosure(page)
        }

        var itemModelCalled: Bool { itemModelCalls > 0 }
        var itemModelCalls: Int = 0
        var itemModelClosure: (Int, Int, (CollectionViewCellModel) ->Void) -> Void = { _, _, _ in }
        func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void) {
            itemModelCalls += 1
            itemModelClosure(page, index, completion)
        }

        var headerModelCalled: Bool { headerModelCalls > 0 }
        var headerModelCalls: Int = 0
        var headerModelClosure: (Int, (CollectionViewHeaderModel) ->Void) -> Void = { _, _ in }
        func headerModel(on page: Int, completion: @escaping (CollectionViewHeaderModel) ->Void) {
            headerModelCalls += 1
            headerModelClosure(page, completion)
        }

        var loadNextPageCalled: Bool { loadNextPageCalls > 0 }
        var loadNextPageCalls: Int = 0
        func loadNextPage() {
            loadNextPageCalls += 1
        }
    }

    func makeSut(presenter: CollectionPresenting? = nil) -> CollectionViewController {
        let collectionView = CollectionViewController()
        collectionView.presenter = presenter
        return collectionView
    }

    func test_viewController_onViewDidLoad_tellsPresenterToLoadCollection() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()

        XCTAssertTrue(presenter.loadCollectionCalled)
    }

    func test_viewController_onViewDidLoad_tellsPresenterToLoadCollectionOnce() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()

        XCTAssertEqual(presenter.loadCollectionCalls, 1)
    }

    func test_viewController_onConfigure_setsTitle() {
        let title = "Test Title"
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: title))

        XCTAssertEqual(sut.titleLabel.text, title)
    }

    func test_viewController_onUpdateCollection_askPresenterForNumberOfPages() {
        var numberOfPages = 0
        let presenter = Presenter()
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        presenter.numberOfItemsClosure = {_ in 1 }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()

        XCTAssertTrue(presenter.numberOfPagesCalled)
    }

    func test_viewController_onUpdateCollection_askPresenterForHeaderModel() {
        var numberOfPages = 0
        let presenter = Presenter()
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        presenter.numberOfItemsClosure = {_ in 1 }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()

        XCTAssertTrue(presenter.headerModelCalled)
    }

    func test_viewController_onUpdateCollection_askPresenterForNumberOfItems() {
        var numberOfPages = 0
        let presenter = Presenter()
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        presenter.numberOfItemsClosure = {_ in 1 }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()

        XCTAssertTrue(presenter.numberOfItemsCalled)

    }

    func test_viewController_onUpdateCollection_askPresenterForItemModel() {
        var numberOfPages = 0
        let presenter = Presenter()
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        presenter.numberOfItemsClosure = {_ in 1 }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()

        XCTAssertTrue(presenter.itemModelCalled)

    }

    func test_viewController_onDisplayLastCell_tellPresenterToLoadNextPage() {
        let presenter = Presenter()
        presenter.numberOfItemsClosure = {_ in 10 }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        XCTAssertTrue(presenter.loadNextPageCalled)

    }

}

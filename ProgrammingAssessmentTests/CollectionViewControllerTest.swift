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
        var numberOfItemsClosure: (Int) -> Int = { _ in 2 }
        func numberOfItems(on page: Int) -> Int {
            numberOfItemsCalls += 1
            return numberOfItemsClosure(page)
        }

        var itemModelCalled: Bool { itemModelCalls > 0 }
        var itemModelCalls: Int = 0
        var itemModelClosure: (Int, Int, @escaping (CollectionViewCellModel) ->Void) -> Void = { _, _, _ in }
        func itemModel(on page: Int, at index:Int, completion: @escaping (CollectionViewCellModel) ->Void) {
            itemModelCalls += 1
            itemModelClosure(page, index, completion)
        }

        var headerModelCalled: Bool { headerModelCalls > 0 }
        var headerModelCalls: Int = 0
        var headerModelClosure: (Int, @escaping (CollectionViewHeaderModel) ->Void) -> Void = { _, _ in }
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
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()

        XCTAssertTrue(presenter.itemModelCalled)

    }

    func test_viewController_onMultipleCellLoading_doNotLoadCellModelTwice() {
        var callsForIndexPath: Int = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {page, item, _ in
            if indexPath.section == page && indexPath.row == item {
                callsForIndexPath += 1
            }
        }
        let sut = makeSut(presenter: presenter)

        _ = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)
        _ = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath)

        XCTAssertEqual(callsForIndexPath, 1)
    }

    func test_viewController_onDisplayLastCell_tellPresenterToLoadNextPage() {
        let presenter = Presenter()
        presenter.itemModelClosure = {page, page, completion in
            completion(CollectionViewCellModel(imageData: Data(), title: ""))
        }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        XCTAssertTrue(presenter.loadNextPageCalled)

    }

    func test_viewController_onDisplayLastCell_waitForLoadingCellBeforeLoadNextPage() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        _ = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: sut.lastIndexPath)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        XCTAssertFalse(presenter.loadNextPageCalled)
    }


    func test_viewController_onMultipleDisplayLastCell_afterLoadtellPresenterToLoadNextPageOnce() {
        var completions: [(CollectionViewCellModel) ->Void] = []
        let presenter = Presenter()
        presenter.itemModelClosure = {_, _, completion in
            completions.append(completion)
        }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        completions.forEach { $0(CollectionViewCellModel(imageData: Data(), title: "")) }

        XCTAssertEqual(presenter.loadNextPageCalls, 1)

    }
}

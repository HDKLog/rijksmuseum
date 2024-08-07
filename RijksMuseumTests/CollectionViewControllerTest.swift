import XCTest

@testable import RijksMuseum
final class CollectionViewControllerTest: XCTestCase {

    class Presenter: CollectionPresenting {

        var chooseItemCalled: Bool { chooseItemCalls > 0 }
        var chooseItemCalls: Int = 0
        var chooseItemClosure: (IndexPath) -> Void = {_ in  }
        func chooseItem(at indexPath: IndexPath) {
            chooseItemCalls += 1
            chooseItemClosure(indexPath)
        }


        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionClosure: () -> Void = { }
        func loadCollection() {
            loadCollectionCalls += 1
            loadCollectionClosure()
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
        var itemModelClosure: (IndexPath, @escaping (CollectionViewCellModel) ->Void) -> Void = { _, _ in }
        func itemModel(at indexPath: IndexPath, completion: @escaping (RijksMuseum.CollectionViewCellModel) -> Void) {
            itemModelCalls += 1
            itemModelClosure(indexPath, completion)
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
        var loadNextPageClosure: () -> Void = { }
        func loadNextPage() {
            loadNextPageCalls += 1
            loadNextPageClosure()
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

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: false, firstScreenText: nil))

        XCTAssertEqual(sut.titleLabel.text, title)
    }

    func test_viewController_onSetup_InitialViewIsHidden() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        XCTAssertTrue(sut.backgroundView.isHidden)
    }

    func test_viewController_onConfigure_withFirstScreenTextShowsInitialView() {
        let title = "Test Title"
        let firstScreenText = "Something..."
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: true, firstScreenText: firstScreenText))

        XCTAssertFalse(sut.backgroundView.isHidden)
    }

    func test_viewController_onConfigure_withFirstScreenTextShowsText() {
        let title = "Test Title"
        let firstScreenText = "Something..."
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: true, firstScreenText: firstScreenText))

        XCTAssertEqual(sut.initialViewLabel.text, firstScreenText)
    }

    func test_viewController_onConfigure_withEmptyFirstScreenTextHideInitialView() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: nil, animatingLoad: true, firstScreenText: nil))

        XCTAssertTrue(sut.backgroundView.isHidden)
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

    func test_viewController_displayError_displayErrorLocalizedDescription() {
        let error = NSError(domain: "testDomain", code: 0)
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.loadViewIfNeeded()
        sut.displayError(error: error)

        let presentedController = sut.presentedViewController as? UIAlertController
        XCTAssertEqual(presentedController?.message, error.localizedDescription)
    }

    func test_viewController_onMultipleCellLoading_doNotLoadCellModelTwice() {
        var callsForIndexPath: Int = 0
        let currentIndexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {indexPath, _ in
            if indexPath == currentIndexPath {
                callsForIndexPath += 1
            }
        }
        let sut = makeSut(presenter: presenter)

        _ = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: currentIndexPath)
        _ = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: currentIndexPath)

        XCTAssertEqual(callsForIndexPath, 1)
    }

    func test_viewController_onLoadCell_setImageforCell() {
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {_, completion in
            completion(.mocked)
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath) as? CollectionViewCell

        XCTAssertNotNil( cell?.itemTileView.imageView.image)
    }

    func test_viewController_onLoadCell_setDescription() {
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {_, completion in
            completion(.mocked)
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath) as? CollectionViewCell

        XCTAssertEqual( cell?.itemTileView.descriptionLabel.text, CollectionViewCellModel.mocked.tileModel.title)
    }

    func test_viewController_onLoadHeader_setHeaderTitle() {
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.headerModelClosure = {page, completion in
            completion(.mocked)
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let header = sut.collectionView.dataSource?.collectionView?(sut.collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? CollectionViewHeader

        XCTAssertEqual( header?.textLabel.text, CollectionViewHeaderModel.mocked.title)
    }

    func test_viewController_onDisplayLastCell_tellPresenterToLoadNextPage() {
        let presenter = Presenter()
        presenter.itemModelClosure = {_, completion in
            completion(.mocked)
        }
        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        presenter.loadCollectionClosure = { expectation.fulfill() }
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()
        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        wait(for: [expectation], timeout: 2)
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
        let presenter = Presenter()
        presenter.itemModelClosure = {_, completion in
            completion(.mocked)
        }
        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        presenter.loadCollectionClosure = { expectation.fulfill() }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)


        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(presenter.loadNextPageCalls, 1)

    }

    func test_viewController_onSelectCell_tellPresenterToChooseCell() {
        let presenter = Presenter()
        presenter.itemModelClosure = {_, completion in
            completion(.mocked)
        }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, didSelectItemAt: sut.lastIndexPath)

        XCTAssertTrue(presenter.chooseItemCalled)

    }
}

extension CollectionViewCellModel {
    static var mocked: CollectionViewCellModel {
        CollectionViewCellModel(tileModel: .init(imageData: UIImage(named: "AppIcon")!.pngData()!, title: "Title"))
    }
}

extension CollectionViewHeaderModel {
    static var mocked: CollectionViewHeaderModel {
        CollectionViewHeaderModel(title: "Page 0")
    }
}

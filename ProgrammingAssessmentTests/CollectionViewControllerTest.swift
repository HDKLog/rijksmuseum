import XCTest

@testable import ProgrammingAssessment
final class CollectionViewControllerTest: XCTestCase {

    class Presenter: CollectionPresenting {

        var chooseItemCalled: Bool { chooseItemCalls > 0 }
        var chooseItemCalls: Int = 0
        var chooseItemClosure: (Int, Int) -> Void = {_, _ in  }
        func chooseItem(itemIndex: Int, on page: Int) {
            chooseItemCalls += 1
            chooseItemClosure(itemIndex, page)
        }


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

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: false, firstScreenText: nil))

        XCTAssertEqual(sut.titleLabel.text, title)
    }

    func test_viewController_onSetup_InitialViewIsHidden() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        XCTAssertTrue(sut.initialView.isHidden)
    }

    func test_viewController_onConfigure_withFirstScreenTextShowsInitialView() {
        let title = "Test Title"
        let firstScreenText = "Something..."
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: true, firstScreenText: firstScreenText))

        XCTAssertFalse(sut.initialView.isHidden)
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
        let title = "Test Title"
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.configure(with: CollectionViewModel(title: title, animatingLoad: true, firstScreenText: nil))

        XCTAssertTrue(sut.initialView.isHidden)
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

    func test_viewController_onLoadCell_setImageforCell() {
        let image = UIImage.init(systemName: "heart.fill")!
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {page, item, completion in
            completion(CollectionViewCellModel(imageData: image.pngData()!, title: ""))
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath) as? CollectionViewCell

        XCTAssertNotNil( cell?.imageView.image)
    }

    func test_viewController_onLoadCell_setDescription() {
        let description = "Description"
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.itemModelClosure = {page, item, completion in
            completion(CollectionViewCellModel(imageData: Data(), title: description))
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let cell = sut.collectionView.dataSource?.collectionView(sut.collectionView, cellForItemAt: indexPath) as? CollectionViewCell

        XCTAssertEqual( cell?.descriptionLabel.text, description)
    }

    func test_viewController_onLoadHeader_setHeaderTitle() {
        let title = "Title"
        var numberOfPages = 0
        let indexPath = IndexPath(row: 0, section: 0)
        let presenter = Presenter()
        presenter.headerModelClosure = {page, completion in
            completion(CollectionViewHeaderModel(title: title))
        }
        presenter.numberOfPagesClosure = {
            numberOfPages += 1
            return numberOfPages
        }
        let sut = makeSut(presenter: presenter)

        sut.updateCollection()
        let header = sut.collectionView.dataSource?.collectionView?(sut.collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? CollectionViewHeader

        XCTAssertEqual( header?.textLabel.text, title)
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
        let presenter = Presenter()
        presenter.itemModelClosure = {_, _, completion in
            completion(CollectionViewCellModel(imageData: Data(), title: ""))
        }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)
        sut.collectionView.delegate?.collectionView?(sut.collectionView, willDisplay: UICollectionViewCell(), forItemAt: sut.lastIndexPath)

        XCTAssertEqual(presenter.loadNextPageCalls, 1)

    }

    func test_viewController_onSelectCell_tellPresenterToChooseCell() {
        let presenter = Presenter()
        presenter.itemModelClosure = {_, _, completion in
            completion(CollectionViewCellModel(imageData: Data(), title: ""))
        }
        let sut = makeSut(presenter: presenter)

        sut.collectionView.delegate?.collectionView?(sut.collectionView, didSelectItemAt: sut.lastIndexPath)

        XCTAssertTrue(presenter.chooseItemCalled)

    }
}

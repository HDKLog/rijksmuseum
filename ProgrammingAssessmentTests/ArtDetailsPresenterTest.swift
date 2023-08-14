import XCTest

@testable import ProgrammingAssessment
class ArtDetailsPresenterTest: XCTestCase {
    class View:ArtDetailsView {

        var configureCalled: Bool { configureCalls > 0 }
        var configureCalls: Int = 0
        var configureClosure: (ArtDetailsViewModel.InitialInfo) -> Void = {_ in }
        func configure(with model: ArtDetailsViewModel.InitialInfo) {
            configureCalls += 1
            configureClosure(model)
        }

        var updateDetailsCalled: Bool { updateDetailsCalls > 0 }
        var updateDetailsCalls: Int = 0
        var updateDetailsClosure: (ArtDetailsViewModel.ArtDetails) -> Void = {_ in }
        func updateDetails(with model: ArtDetailsViewModel.ArtDetails) {
            updateDetailsCalls += 1
            updateDetailsClosure(model)
        }


    }

    class Interactor: ArtDetailsInteracting {

        var loadArtDetailsCalled: Bool { loadArtDetailsCalls > 0 }
        var loadArtDetailsCalls: Int = 0
        var loadArtDetailsClosure: (String,  @escaping ArtDetailsLoadingResultHandler) -> Void = {_, _ in }
        func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
            loadArtDetailsCalls += 1
            loadArtDetailsClosure(artId, completion)
        }

        var loadCollectionItemImageDataCalled: Bool { loadCollectionItemImageDataCalls > 0 }
        var loadCollectionItemImageDataCalls: Int = 0
        var loadCollectionItemImageDataClosure: (URL,  @escaping ArtDetailsImageLoadingResultHandler) -> Void = {_, _ in }
        func loadCollectionItemImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
            loadCollectionItemImageDataCalls += 1
            loadCollectionItemImageDataClosure(url, completion)
        }


    }

    class Router: ArtDetailsRouting {
        var routeToCollectionCalled: Bool { routeToCollectionCalls > 0 }
        var routeToCollectionCalls: Int = 0
        var routeToCollectionClosure: () -> Void = { }
        func routeToCollection() {
            routeToCollectionCalls += 1
            routeToCollectionClosure()
        }


    }

    func makeSut(view: ArtDetailsView, interactor: ArtDetailsInteracting, router: ArtDetailsRouting? = nil) -> ArtDetailsPresenter {
        let presenter = ArtDetailsPresenter(view: view, interactor: interactor)
        presenter.router = router
        return presenter
    }

    func test_artDetailsPresenter_onLoadView_configureView() {
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadView()

        XCTAssertTrue(view.configureCalled)
    }

    func test_artDetailsPresenter_onLoadView_configureViewOnce() {
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadView()

        XCTAssertEqual(view.configureCalls, 1)
    }

    func test_artDetailsPresenter_onLoadArt_loadsArtFromInteractor() {

        let artId = "artId"
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertTrue(interactor.loadArtDetailsCalled)
    }

    func test_artDetailsPresenter_onLoadArt_loadsArtFromInteractorOnce() {

        let artId = "artId"
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertEqual(interactor.loadArtDetailsCalls, 1)
    }

    func test_artDetailsPresenter_onLoadArt_loadsArtFromInteractorWithId() {

        let artId = "artId"
        var loadedId: String?
        let view = View()
        let interactor = Interactor()

        interactor.loadArtDetailsClosure = { artId, _ in
            loadedId = artId
        }

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertEqual(loadedId, loadedId)
    }
}

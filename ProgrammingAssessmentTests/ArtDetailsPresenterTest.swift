import XCTest

@testable import ProgrammingAssessment
class ArtDetailsPresenterTest: XCTestCase {
    class View: ArtDetailsView {

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

        var updateImageCalled: Bool { updateImageCalls > 0 }
        var updateImageCalls: Int = 0
        var updateImageClosure: (Data) -> Void = {_ in }
        func updateImage(with data: Data) {
            updateImageCalls += 1
            updateImageClosure(data)
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

        var loadArtDetailsImageDataCalled: Bool { loadArtDetailsImageDataCalls > 0 }
        var loadArtDetailsImageDataCalls: Int = 0
        var loadArtDetailsImageDataClosure: (URL,  @escaping ArtDetailsImageLoadingResultHandler) -> Void = {_, _ in }
        func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
            loadArtDetailsImageDataCalls += 1
            loadArtDetailsImageDataClosure(url, completion)
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

    func test_artDetailsPresenter_onLoadArt_loadsArtDetailsFromInteractor() {

        let artId = "artId"
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertTrue(interactor.loadArtDetailsCalled)
    }

    func test_artDetailsPresenter_onLoadArt_loadsArtDetailsFromInteractorOnce() {

        let artId = "artId"
        let view = View()
        let interactor = Interactor()

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertEqual(interactor.loadArtDetailsCalls, 1)
    }

    func test_artDetailsPresenter_onLoadArt_loadsArtDetailsFromInteractorWithId() {

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

    func test_artDetailsPresenter_onLoadArt_loadsArtDetailsSuccessLoadImage() {

        let artId = "artId"
        let artDetails = ArtDetails.mocked
        let view = View()
        let interactor = Interactor()

        interactor.loadArtDetailsClosure = { _, completion in
            completion(.success(artDetails))
        }

        let sut = makeSut(view: view, interactor: interactor)

        sut.loadArt(artId: artId)

        XCTAssertTrue(interactor.loadArtDetailsImageDataCalled)
    }

    func test_artDetailsPresenter_onRoutBack_tellsRouterRouteToCollection() {

        let view = View()
        let interactor = Interactor()
        let router = Router()

        let sut = makeSut(view: view, interactor: interactor, router: router)

        sut.routBack()

        XCTAssertTrue(router.routeToCollectionCalled)
    }
}

extension ArtDetails {
    static var mocked: ArtDetails {
        let image = ArtDetails.Image(guid: "", width: 0, height: 0, url: URL(string: "https://www.google.com/"))
        return ArtDetails(id: "", title: "", description: "", webImage: image)
    }
}

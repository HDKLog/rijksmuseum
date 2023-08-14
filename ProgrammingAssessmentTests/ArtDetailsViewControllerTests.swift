import XCTest

@testable import ProgrammingAssessment
class ArtDetailsViewControllerTests: XCTestCase {

    class Presenter: ArtDetailsPresenting {

        var loadViewCalled: Bool { loadViewCalls > 0 }
        var loadViewCalls: Int = 0
        var loadViewClosure:() -> Void = { }
        func loadView() {
            loadViewCalls += 1
            loadViewClosure()
        }

        var loadArtCalled: Bool { loadArtCalls > 0 }
        var loadArtCalls: Int = 0
        var loadArtClosure:(String) -> Void = {_ in }
        func loadArt(artId: String) {
            loadArtCalls += 1
            loadArtClosure(artId)
        }
    }

    func makeSut(presenter: ArtDetailsPresenting? = nil) -> ArtDetailsViewController {
        let sut = ArtDetailsViewController()
        sut.presenter = presenter
        return sut
    }

    func test_viewController_onViewDidLoad_callsLoadView() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()

        XCTAssertTrue(presenter.loadViewCalled)
    }



}

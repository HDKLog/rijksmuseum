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

        var routBackCalled: Bool { routBackCalls > 0 }
        var routBackCalls: Int = 0
        var routBackClosure:() -> Void = { }
        func routBack() {
            routBackCalls += 1
            routBackClosure()
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

    func test_viewController_onBackButtonTap_tellPresenterToRoutBack() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()
        sut.configure(with: ArtDetailsViewModel.InitialInfo(backButtonTitle: "Title"))
        let item = sut.navigationItem.leftBarButtonItem

        _ = item?.target?.perform(item?.action, with: nil)

        XCTAssertTrue(presenter.routBackCalled)
    }

}

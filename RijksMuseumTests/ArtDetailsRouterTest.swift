import XCTest

@testable import RijksMuseum
final class ArtDetailsRouterTest: XCTestCase {

    func makeSut(navigationController: UINavigationController = UINavigationController()) -> ArtDetailsRouter {
        ArtDetailsRouter(navigationController: navigationController)
    }

    func test_artDetailsRouter_onRouteToCollection_popToPreviousView() {

        let navigationController = UINavigationController(rootViewController: UIViewController())
        let presentedController = UIViewController()
        navigationController.pushViewController(presentedController, animated: false)

        let sut = makeSut(navigationController: navigationController)

        sut.routeToCollection()

        XCTAssertFalse(navigationController.viewControllers.contains(presentedController))
    }
}

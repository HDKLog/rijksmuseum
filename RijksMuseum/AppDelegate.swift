import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()

        let artDetailsViewController = createArtDetails()
        let collectionViewController = createCollection(endView: artDetailsViewController, routingEndpoint: artDetailsViewController)

        window?.rootViewController = UINavigationController(rootViewController: collectionViewController)
        window?.makeKeyAndVisible()

        return true
    }


}


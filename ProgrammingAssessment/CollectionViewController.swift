import UIKit

protocol CollectionView {
    
}

class CollectionViewController: UIViewController, CollectionView {

    var presenter: CollectionPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        presenter?.loadCollection()
    }


}


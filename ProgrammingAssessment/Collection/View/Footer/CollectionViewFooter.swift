import UIKit

class CollectionViewFooter: UICollectionReusableView {

    static let resuableId = "CollectionViewFooter"

    var indicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup(){
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

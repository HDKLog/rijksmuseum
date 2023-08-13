import UIKit

class CollectionViewHeader: UICollectionReusableView {
    static let resuableId = "CollectionViewHeader"

    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = DesignBook.Color.Foreground.light.uiColor()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: DesignBook.Layout.Sizes.Text.Font.medium)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.backgroundColor = .clear
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        textLabel.text = "Header"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {

        self.addSubview(textLabel)

        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: DesignBook.Layout.Spacing.medium),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignBook.Layout.Spacing.medium),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignBook.Layout.Spacing.medium),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -DesignBook.Layout.Spacing.medium)
        ])
    }

    func configure(with model:CollectionViewHeaderModel) {
        self.textLabel.text = model.title
    }

}

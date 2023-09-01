import UIKit
import SkeletonView

class CollectionViewCell: UICollectionViewCell {

    static let reusableId = "CollectionViewCell"

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .blue
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = DesignBook.Color.Foreground.inverse.uiColor()
        label.font = UIFont.systemFont(ofSize: DesignBook.Layout.Sizes.Text.Font.small)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentViews()
        setupSkeletonAnimation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentViews() {

        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor

        self.contentView.addSubview(imageView)
        setupImageViewConstraints()

        self.contentView.addSubview(descriptionLabel)
        setupDescriptionLabelConstraints()

    }

    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    private func setupDescriptionLabelConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    private func setupSkeletonAnimation() {

        isSkeletonable = true

        contentView.isSkeletonable = true

        imageView.isSkeletonable = true

        descriptionLabel.isSkeletonable = true
        descriptionLabel.skeletonTextNumberOfLines = .custom(1)
    }


    func configure(with model: CollectionViewCellModel) {
        contentView.hideSkeleton()
        imageView.image = UIImage(data: model.imageData)
        descriptionLabel.text = model.title
    }

    func reset() {
        contentView.showAnimatedGradientSkeleton()
        imageView.image = nil
        descriptionLabel.text = nil
    }
}

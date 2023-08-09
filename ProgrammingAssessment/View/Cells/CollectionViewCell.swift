//
//  CollectionViewCell.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
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
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: DesignBook.Layout.Sizes.Text.small)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentViews()

        let url = URL(string: "https://lh3.googleusercontent.com/SjuKgVllMl-wQ9sRUXch29gQpNg2NDiNSRsPGft0CzbGOIFwZktLNz7_689URZOGxOHFO76B722WD1RibHoBdOm7csga=s0")

        DispatchQueue.global().async { [weak self] in
            let data = try? Data(contentsOf: url!)

            data.flatMap { [weak self] data in

                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
        self.descriptionLabel.text = "De dans om het gouden kalf, Lucas van Leyden, ca. 1530"

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentViews() {

        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor

        self.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }


    func configure(with model: CollectionViewCellModel) {
        imageView.image = UIImage(data: model.imageData)
        descriptionLabel.text = model.title
    }
}

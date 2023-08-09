//
//  CollectionViewHeader.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {


    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .blue
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentViews() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }


    func configure(with model: CollectionViewHeaderModel) {
        imageView.image = UIImage(data: model.imageData)
    }

}

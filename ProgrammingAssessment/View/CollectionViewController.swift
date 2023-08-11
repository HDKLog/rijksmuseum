import UIKit

protocol CollectionView {
    func configure(with model: CollectionViewModel)
    func updateCollection()
}

class CollectionViewController: UIViewController, CollectionView {

    var presenter: CollectionPresenting?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignBook.Color.Foreground.light.uiColor()
        label.font = UIFont.systemFont(ofSize: DesignBook.Layout.Sizes.Text.Font.large)
        return label
    }()

    lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = DesignBook.Layout.Spacing.medium
        layout.minimumInteritemSpacing = DesignBook.Layout.Spacing.medium
        layout.sectionInset = UIEdgeInsets(top: 0, left: DesignBook.Layout.Spacing.medium, bottom: 0, right: DesignBook.Layout.Spacing.medium)
        layout.itemSize = CGSize(width: (view.frame.width - DesignBook.Layout.Spacing.medium * 3)/2, height: DesignBook.Layout.Sizes.Image.medium)

        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCellModel.resuableId)
        //collectionView.register(IndicatorCell.self, forCellWithReuseIdentifier: indicatorCellID)
        collectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaderModel.resuableId)
        collectionView.backgroundColor = DesignBook.Color.Background.list.uiColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadCollection()
    }

    private func setup() {
        view.backgroundColor = DesignBook.Color.Background.list.uiColor()
        setupTitle()
        setupCollectionView()
    }

    private func setupTitle() {
        navigationItem.titleView = titleLabel
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func configure(with model: CollectionViewModel) {
        titleLabel.text = model.title
    }
    func updateCollection() {
        
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        100
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellModel.resuableId, for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaderModel.resuableId, for: indexPath)

        return header
    }

}

extension CollectionViewController: UICollectionViewDelegate {

}

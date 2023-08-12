import UIKit
import SkeletonView

protocol CollectionView {
    func configure(with model: CollectionViewModel)
    func updateCollection()
    func displayError(error: Error)
}

class CollectionViewController: UIViewController, CollectionView {

    var presenter: CollectionPresenting?

    var cachedItemsModels: [IndexPath: CollectionViewCellModel] = [:]
    var loadingNextPage = false
    var loadingIndexPaths: Set<IndexPath> = []

    let loadingGroup = DispatchGroup()

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
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: DesignBook.Layout.Spacing.medium,
                                           bottom: 0,
                                           right: DesignBook.Layout.Spacing.medium)
        layout.itemSize = CGSize(width: (view.frame.width - DesignBook.Layout.Spacing.medium * 3)/2,
                                 height: DesignBook.Layout.Sizes.Image.medium)
        layout.headerReferenceSize = CGSize(width: view.frame.width,
                                            height: DesignBook.Layout.Sizes.Text.Header.medium)
        layout.footerReferenceSize = CGSize(width: view.frame.width,
                                            height: DesignBook.Layout.Sizes.Text.Header.medium)

        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.resuableId)
        collectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.resuableId)
        collectionView.register(CollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewFooter.resuableId)
        collectionView.backgroundColor = DesignBook.Color.Background.list.uiColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPrefetchingEnabled = false

        return collectionView

    }()

    var lastIndexPath: IndexPath {
        let lastSection = collectionView.numberOfSections-1
        let lastSectionLastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        return IndexPath(row: max(lastSectionLastItem, 0), section: max(lastSection, 0))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadCollection()
    }

    private func setup() {
        view.backgroundColor = DesignBook.Color.Background.main.uiColor()
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
        collectionView.insertSections(IndexSet(integer: collectionView.numberOfSections))
        loadingNextPage = false
    }

    func displayError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        CollectionViewCell.resuableId
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.numberOfItems(on: section) ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter?.numberOfPages() ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.resuableId, for: indexPath)
        if let collectionCell = cell as? CollectionViewCell {

            collectionCell.reset()

            if let model = cachedItemsModels[indexPath] {
                collectionCell.configure(with: model)
            } else if !loadingIndexPaths.contains(indexPath) {
                loadingGroup.enter()
                loadingIndexPaths.insert(indexPath)
                presenter?.itemModel(on: indexPath.section, at: indexPath.row) { model in

                    self.loadingGroup.leave()
                    self.cachedItemsModels[indexPath] = model
                    self.loadingIndexPaths.remove(indexPath)

                    if let configurableCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                        configurableCell.configure(with: model)
                    }

                }
            }

        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionViewHeader(for: collectionView, at: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionViewFooter(for: collectionView, at: indexPath)
        default:
            return UICollectionReusableView()
        }

    }

    private func collectionViewHeader(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     withReuseIdentifier: CollectionViewHeader.resuableId,
                                                                     for: indexPath)
        if let collectionHeader = header as? CollectionViewHeader {
            presenter?.headerModel(on: indexPath.section) { model in
                collectionHeader.configure(with: model)
            }

        }
        return header
    }

    private func collectionViewFooter(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     withReuseIdentifier: CollectionViewFooter.resuableId,
                                                                     for: indexPath)
        //footer.isHidden = true
        return footer
    }

}

extension CollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSection = collectionView.numberOfSections-1
        let lastSectionLastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        let lastIndexPath = IndexPath(row: max(lastSectionLastItem, 0), section: max(lastSection, 0))
        if indexPath == lastIndexPath, !loadingNextPage {
            loadingNextPage = true
            DispatchQueue.global().async {
                self.loadingGroup.wait()
                self.presenter?.loadNextPage()
            }

        }
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        lastIndexPath.section == section ? CGSize(width: view.frame.width,
                                                  height: DesignBook.Layout.Sizes.Text.Header.medium) : .zero
    }
}

import Foundation

struct CollectionPage {
    struct CollectionItem {
        struct Image {
            let guid: String?
            let width: Int
            let height: Int
            let url: URL?
        }

        let id: String
        let title: String
        let description: String
        let webImage: Image?
        let headerImage: Image?
    }

    let title: String?
    let items: [CollectionItem]
}

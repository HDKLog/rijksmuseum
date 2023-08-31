import Foundation

struct CollectionInfo: Codable {
    struct Art: Codable {
        struct ImageInfo: Codable {
            let guid: String
            let offsetPercentageX: Int
            let offsetPercentageY: Int
            let width: Int
            let height: Int
            let url: String
        }

        let links: [String : String]
        let id: String
        let objectNumber: String
        let title: String
        let hasImage: Bool
        let principalOrFirstMaker: String
        let longTitle: String
        let showImage: Bool
        let permitDownload: Bool
        let webImage: ImageInfo
        let headerImage: ImageInfo
        let productionPlaces: [String]
    }

    let elapsedMilliseconds: Int
    let count: UInt64
    let artObjects: [Art]
}

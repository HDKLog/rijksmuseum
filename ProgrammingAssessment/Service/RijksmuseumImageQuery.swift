import Foundation

class RijksmuseumImageQuery: ServiceQuery {

    var scale: Int = 0
    let url: String

    init(url: String) {
        self.url = url
    }

    func withScale(scale: Int) -> RijksmuseumImageQuery {
        self.scale = scale
        return self
    }

    func getUrl() -> URL? {
        return URL(string: "\(url)\(scale)")
    }
}

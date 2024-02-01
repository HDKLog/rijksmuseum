import Foundation

class RijksmuseumImageQuery: ServiceQuery {

    var scale: Int? = nil
    let url: String

    init(url: String) {
        self.url = url
    }

    func withScale(scale: Int) -> RijksmuseumImageQuery {
        self.scale = scale
        return self
    }

    func getUrl() -> URL? {
        let appendix = scale.flatMap { "\($0)" } ?? ""
        return URL(string: "\(url)\(appendix)")
    }
}

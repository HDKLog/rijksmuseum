//
//  RijksmuseumServiceJsonQuery.swift
//  ProgrammingAssessment
//
//  Created by Gari Sarkisyan on 14.08.23.
//

import Foundation

class RijksmuseumServiceQuery: ServiceQuery {

    enum Format: String {
        case json
        case jsonp
        case xml
    }

    enum Culture: String {
        case en
        case nl
    }

    enum Request: CustomStringConvertible {

        case all
        case collection(String)
        case tiles(String)

        var description: String {
            switch self {
            case .all:
                return "collection"
            case let .collection(id):
                return "collection/\(id)"
            case let .tiles(id):
                return "collection/\(id)/tiles"
            }
        }
    }

    let baseUrl = "https://www.rijksmuseum.nl/api"
#warning("provide API KEY")
    let key = ""
    var format: Format = .json
    var culture: Culture = .en
    var request: Request
    var page: Int = 0
    var pageSize: Int = 10

    init(request: Request) {
        self.request = request
    }

    func withFormat(format: Format) -> RijksmuseumServiceQuery {
        self.format = format
        return self
    }

    func withCulture(culture: Culture) -> RijksmuseumServiceQuery {
        self.culture = culture
        return self
    }

    func withPage(page: Int) -> RijksmuseumServiceQuery {
        self.page = page
        return self
    }

    func withPageSize(pageSize: Int) -> RijksmuseumServiceQuery {
        self.pageSize = pageSize
        return self
    }

    func getUrl() -> URL? {
        URL(string:"\(baseUrl)/\(culture.rawValue)/\(request.description)?key=\(key)&format=\(format.rawValue)&p=\(page)&ps=\(pageSize)")
    }
}

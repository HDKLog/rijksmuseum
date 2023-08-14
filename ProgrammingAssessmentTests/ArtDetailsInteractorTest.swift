import XCTest

@testable import ProgrammingAssessment
class ArtDetailsInteractorTest: XCTestCase {
    class Service: ServiceLoading {

        var getDataCalled: Bool { getDataCalls > 0 }
        var getDataCalls: Int = 0
        var getDataClosure: (ServiceQuery, @escaping ServiceLoadingResultHandler) -> Void = { _, _ in }
        func getData(query: ServiceQuery, completion: @escaping ServiceLoadingResultHandler) {
            getDataCalls += 1
            getDataClosure(query, completion)
        }
    }

    var artDetailsInfo: ArtDetailsInfo {
        let image = ArtDetailsInfo.Art.ImageInfo(
            guid: "guid",
            offsetPercentageX: 0,
            offsetPercentageY: 1,
            width: 2500,
            height: 2034,
            url: "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0")

        return ArtDetailsInfo(
            artObject: ArtDetailsInfo.Art(
                id: "id",
                priref: "123",
                objectNumber: "Number",
                language: "en",
                title: "Title",
                webImage: image,
                description: "Desc"
            )
        )
    }

    var artDetails: ArtDetails { artDetailsInfo.artDetails }

    func makeSut(service: ServiceLoading) -> ArtDetailsInteractor {
        ArtDetailsInteractor(service: service)
    }

    func test_artDetailsInteractor_onLoadArtDetails_tellsServiceToLoadCollection() {
        let service = Service()
        let sut = makeSut(service: service)

        sut.loadArtDetails(artId: "id"){_ in }

        XCTAssertTrue(service.getDataCalled)
    }

    func test_artDetailsInteractor_onLoadArtDetails_tellsServiceToLoadArtDetails() {
        let artId = "id"
        var serviceQuery: ServiceQuery?
        let service = Service()
        service.getDataClosure = { query, completion in
            serviceQuery = query
        }
        let sut = makeSut(service: service)

        sut.loadArtDetails(artId: artId) {_ in }

        XCTAssertEqual(serviceQuery?.getUrl()?.lastPathComponent, artId)
    }

    func test_artDetailsInteractor_onLoadArtDetails_onSuccessGivesArtDetails() {
        let data = try! JSONEncoder().encode(artDetailsInfo)
        var result: ArtDetailsLoadingResult?
        let service = Service()
        service.getDataClosure = { query, completion in
            completion(.success(data))
        }
        let sut = makeSut(service: service)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetails(artId: "id") {
            result = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(result, .success(artDetails))
    }

    func test_artDetailsInteractor_onLoadArtDetails_onFailureGivesError() {
        let error = ServiceLoadingError.invalidQuery
        var result: ArtDetailsLoadingResult?
        let service = Service()
        service.getDataClosure = { query, completion in
            completion(.failure(error))
        }
        let sut = makeSut(service: service)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetails(artId: "id") {
            result = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(result, .failure(.serviceError(error)))
    }

    func test_artDetailsInteractor_onLoadImage_tellsServiceToLoadUrl() {
        let urlString = "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
        let url = URL(string:urlString)!
        var serviceQuery: ServiceQuery?
        let service = Service()
        service.getDataClosure = { query, completion in
            serviceQuery = query
        }
        let sut = makeSut(service: service)

        sut.loadCollectionItemImageData(from: url) { _ in }

        XCTAssertTrue(serviceQuery?.getUrl()?.absoluteString.contains(urlString) == true)
    }

    func test_artDetailsInteractor_onLoadImage_onSuccessGivesImageData() {
        let urlString = "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
        let url = URL(string:urlString)!
        let imageData = Data(count: 2)
        var loadedImageResult: CollectionImageLoadingResult?
        let service = Service()
        service.getDataClosure = { query, completion in
            completion(.success(imageData))
        }
        let sut = makeSut(service: service)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url) {
            loadedImageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .success(imageData))
    }

    func test_artDetailsInteractor_onLoadImage_onFailureGivesError() {
        let urlString = "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
        let url = URL(string:urlString)!
        let error = ServiceLoadingError.invalidQuery
        var loadedImageResult: CollectionImageLoadingResult?
        let service = Service()
        service.getDataClosure = { query, completion in
            completion(.failure(error))
        }
        let sut = makeSut(service: service)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url) {
            loadedImageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .failure(.serviceError(error)))
    }
}

extension ArtDetails: Equatable {
    public static func == (lhs: ArtDetails, rhs: ArtDetails) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.webImage == rhs.webImage
    }
}

extension ArtDetails.Image: Equatable {
    public static func == (lhs: ArtDetails.Image, rhs: ArtDetails.Image) -> Bool {
        lhs.guid == rhs.guid &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.url == rhs.url
    }
}

extension ArtDetailsLoadingError: Equatable {
    public static func == (lhs: ArtDetailsLoadingError, rhs: ArtDetailsLoadingError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

extension ArtDetailsImageLoadingError: Equatable {
    public static func == (lhs: ArtDetailsImageLoadingError, rhs: ArtDetailsImageLoadingError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

import XCTest

@testable import ProgrammingAssessment
class ArtDetailsInteractorTest: XCTestCase {
    class Gateway: ArtGateway {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionClosure: (Int, Int, CollectionLoadingResultHandler) -> Void = {_, _, _ in }
        func loadCollection(page: Int, count: Int, completion: @escaping CollectionLoadingResultHandler) {
            loadCollectionCalls += 1
            loadCollectionClosure(page, count, completion)
        }

        var loadCollectionImageDataCalled: Bool { loadCollectionImageDataCalls > 0 }
        var loadCollectionImageDataCalls: Int = 0
        var loadCollectionImageDataClosure: (URL, CollectionImageLoadingResultHandler) -> Void = {_, _ in }
        func loadCollectionImageData(from url: URL, completion: @escaping CollectionImageLoadingResultHandler) {
            loadCollectionImageDataCalls += 1
            loadCollectionImageDataClosure(url, completion)
        }

        var loadArtDetailsCalled: Bool { loadArtDetailsCalls > 0 }
        var loadArtDetailsCalls: Int = 0
        var loadArtDetailsClosure: (String, ArtDetailsLoadingResultHandler) -> Void = {_, _ in }
        func loadArtDetails(artId: String, completion: @escaping ArtDetailsLoadingResultHandler) {
            loadArtDetailsCalls += 1
            loadArtDetailsClosure(artId, completion)
        }

        var loadArtDetailsImageDataCalled: Bool { loadArtDetailsImageDataCalls > 0 }
        var loadArtDetailsImageDataCalls: Int = 0
        var loadArtDetailsImageDataClosure: (URL, ArtDetailsImageLoadingResultHandler) -> Void = {_, _ in }
        func loadArtDetailsImageData(from url: URL, completion: @escaping ArtDetailsImageLoadingResultHandler) {
            loadArtDetailsImageDataCalls += 1
            loadArtDetailsImageDataClosure(url, completion)
        }
    }

    var artDetails: ArtDetails { ArtDetailsInfo.mocked.artDetails }

    func makeSut(gateway: Gateway) -> ArtDetailsInteractor {
        ArtDetailsInteractor(gateway: gateway)
    }

    func test_artDetailsInteractor_onLoadArtDetails_tellsServiceToLoadCollection() {
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        sut.loadArtDetails(artId: "id"){_ in }

        XCTAssertTrue(gateway.loadArtDetailsCalled)
    }

    func test_artDetailsInteractor_onLoadArtDetails_tellsServiceToLoadArtDetails() {
        let artId = "id"
        var loadingArtId: String?
        let gateway = Gateway()
        gateway.loadArtDetailsClosure = {id, _ in
            loadingArtId = id
        }
        let sut = makeSut(gateway: gateway)

        sut.loadArtDetails(artId: artId) {_ in }

        XCTAssertEqual(loadingArtId, artId)
    }

    func test_artDetailsInteractor_onLoadArtDetails_onSuccessGivesArtDetails() {
        let info = ArtDetailsInfo.mocked
        let details = ArtDetails.mocked
        var result: ArtDetailsResult?
        let gateway = Gateway()
        gateway.loadArtDetailsClosure = {_, completion in
            completion(.success(info))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetails(artId: "id") {
            result = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(result, .success(details))
    }

    func test_artDetailsInteractor_onLoadArtDetails_onFailureGivesError() {
        let error = ServiceLoadingError.invalidQuery
        var result: ArtDetailsResult?
        let gateway = Gateway()
        gateway.loadArtDetailsClosure = { _, completion in
            completion(.failure(.serviceError(error)))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetails(artId: "id") {
            result = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(result, .failure(.loading(error: .serviceError(error))))
    }

    func test_artDetailsInteractor_onLoadImage_tellsServiceToLoadUrl() {
        let urlString = "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
        let url = URL(string:urlString)!
        var loadingUrl: URL?
        let gateway = Gateway()
        gateway.loadArtDetailsImageDataClosure = { url, _ in
            loadingUrl = url
        }
        let sut = makeSut(gateway: gateway)

        sut.loadArtDetailsImageData(from: url) { _ in }

        XCTAssertEqual(loadingUrl, url)
    }

    func test_artDetailsInteractor_onLoadImage_onSuccessGivesImageData() {
        let urlString = "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
        let url = URL(string:urlString)!
        let imageData = Data(count: 2)
        var loadedImageResult: ArtDetailsImageResult?
        let gateway = Gateway()
        gateway.loadArtDetailsImageDataClosure = { url, completion in
            completion(.success(imageData))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetailsImageData(from: url) {
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
        var loadedImageResult: ArtDetailsImageResult?
        let gateway = Gateway()
        gateway.loadArtDetailsImageDataClosure = { url, completion in
            completion(.failure(.serviceError(error)))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadArtDetailsImageData(from: url) {
            loadedImageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .failure(.loading(error: .serviceError(error))))
    }
}

extension ArtDetailsInfo {
    static var mocked: ArtDetailsInfo {
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

extension ArtDetailsError: Equatable {
    public static func == (lhs: ArtDetailsError, rhs: ArtDetailsError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

extension ArtDetailsImageError: Equatable {
    public static func == (lhs: ArtDetailsImageError, rhs: ArtDetailsImageError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

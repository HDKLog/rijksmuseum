import XCTest

@testable import ProgrammingAssessment
final class CollectionInteractorTest: XCTestCase {

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

    func makeSut(gateway: Gateway) -> CollectionInteractor {
        CollectionInteractor(gateway: gateway)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollection() {
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        sut.loadCollection(page: 0, count: 0) {_ in }

        XCTAssertTrue(gateway.loadCollectionCalled)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollectionPage() {
        let pageToLoad = 1
        var loadedPage: Int?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count, completion in
            loadedPage = page
        }
        let sut = makeSut(gateway: gateway)

        sut.loadCollection(page: pageToLoad, count: 0) {_ in }

        XCTAssertEqual(loadedPage, pageToLoad)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollectionPageSize() {
        let pageSizeToLoad = 1
        var loadedPageSize: Int?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count, completion in
            loadedPageSize = count
        }
        let sut = makeSut(gateway: gateway)

        sut.loadCollection(page: 0, count: pageSizeToLoad) {_ in }

        XCTAssertEqual(loadedPageSize, pageSizeToLoad)
    }

    func test_collectionInteractor_onLoadCollection_onSuccessGivesCollectionPage() {
        var collectionPageResult: CollectionLoadingResult?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count, completion in
            completion(.success(.mocked))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollection(page: 0, count: 3) {
            collectionPageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(collectionPageResult, .success(.mocked))
    }

    func test_collectionInteractor_onLoadCollection_onFailureGivesError() {
        let error = ServiceLoadingError.invalidQuery
        var collectionPageResult: CollectionLoadingResult?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { _, _, completion in
            completion(.failure(.serviceError(error)))
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollection(page: 0, count: 3) {
            collectionPageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(collectionPageResult, .failure(.serviceError(error)))
    }

    func test_loadCollectionItemImageData_onLoadImage_tellsServiceToLoadUrl() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage.url!
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        sut.loadCollectionItemImageData(from: url) { _ in }

        XCTAssertTrue(gateway.loadCollectionImageDataCalled)
    }

    func test_loadCollectionItemImageData_onLoadImage_onSuccessGivesImageData() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage.url!
        let imageData = Data(count: 2)
        var loadedImageResult: CollectionImageLoadingResult?
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        gateway.loadCollectionImageDataClosure = { _, complition in
            complition(.success(imageData))
        }

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url) {
            loadedImageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .success(imageData))
    }

    func test_loadCollectionItemImageData_onLoadImage_onFailureGivesError() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage.url!
        let error = ServiceLoadingError.invalidQuery
        var loadedImageResult: CollectionImageLoadingResult?

        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        gateway.loadCollectionImageDataClosure = { _, completion in
            completion(.failure(.serviceError(error)))
        }

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url) {
            loadedImageResult = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .failure(.serviceError(error)))
    }
}

extension CollectionInfo {
    static var mocked: CollectionInfo {
        let image = CollectionInfo.Art.ImageInfo(
            guid: "bbd1fae8-4023-4859-8ed1-d38616aec96c",
            offsetPercentageX: 0,
            offsetPercentageY: 1,
            width: 5656,
            height: 4704,
            url: "https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0")
        let arts = Array(repeating: CollectionInfo.Art(links: ["String" : "String"],
                                                       id: "en-SK-C-5",
                                                       objectNumber: "SK-C-5",
                                                       title: "The Night Watch",
                                                       hasImage: true,
                                                       principalOrFirstMaker: "Principal",
                                                       longTitle: "The Night Watch, Rembrandt van Rijn, 1642",
                                                       showImage: true,
                                                       permitDownload: true,
                                                       webImage: image,
                                                       headerImage: image,
                                                       productionPlaces: ["Place"]),
                         count: 3)

        return CollectionInfo(
            elapsedMilliseconds: 0,
            count: UInt64(arts.count),
            artObjects: arts)
    }
}

extension CollectionPage: Equatable {
    public static func == (lhs: CollectionPage, rhs: CollectionPage) -> Bool {
        lhs.title == rhs.title &&
        lhs.items == rhs.items
    }
}

extension CollectionPage.CollectionItem: Equatable {
    public static func == (lhs: CollectionPage.CollectionItem, rhs: CollectionPage.CollectionItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.webImage == rhs.webImage &&
        lhs.headerImage == rhs.headerImage
    }
}

extension CollectionPage.CollectionItem.Image: Equatable {
    public static func == (lhs: CollectionPage.CollectionItem.Image, rhs: CollectionPage.CollectionItem.Image) -> Bool {
        lhs.guid == rhs.guid &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.url == rhs.url
    }
}

extension CollectionLoadingError: Equatable {
    public static func == (lhs: CollectionLoadingError, rhs: CollectionLoadingError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

extension CollectionImageLoadingError: Equatable {
    public static func == (lhs: CollectionImageLoadingError, rhs: CollectionImageLoadingError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

import XCTest
import Combine

@testable import RijksMuseum
final class CollectionInteractorTest: XCTestCase {

    class Gateway: ArtGateway {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionClosure: (Int, Int) -> AnyPublisher<CollectionInfo, CollectionLoadingError> = {_, _ in Empty().eraseToAnyPublisher() }
        func loadCollection(page: Int, count: Int) -> AnyPublisher<CollectionInfo, CollectionLoadingError> {
            loadCollectionCalls += 1
            return loadCollectionClosure(page, count)
        }

        var loadCollectionImageDataCalled: Bool { loadCollectionImageDataCalls > 0 }
        var loadCollectionImageDataCalls: Int = 0
        var loadCollectionImageDataClosure: (URL) -> AnyPublisher<Data, CollectionImageLoadingError> = {_ in Empty().eraseToAnyPublisher() }
        func loadCollectionImageData(from url: URL) -> AnyPublisher<Data, CollectionImageLoadingError> {
            loadCollectionImageDataCalls += 1
            return loadCollectionImageDataClosure(url)
        }

        var loadArtDetailsCalled: Bool { loadArtDetailsCalls > 0 }
        var loadArtDetailsCalls: Int = 0
        var loadArtDetailsClosure: (String) -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError> = {_ in Empty().eraseToAnyPublisher() }
        func loadArtDetails(artId: String) -> AnyPublisher<ArtDetailsInfo, ArtDetailsLoadingError> {
            loadArtDetailsCalls += 1
            return loadArtDetailsClosure(artId)
        }

        var loadArtDetailsImageDataCalled: Bool { loadArtDetailsImageDataCalls > 0 }
        var loadArtDetailsImageDataCalls: Int = 0
        var loadArtDetailsImageDataClosure: (URL) -> AnyPublisher<Data, ArtDetailsImageLoadingError> = {_ in Empty().eraseToAnyPublisher() }
        func loadArtDetailsImageData(from url: URL) -> AnyPublisher<Data, ArtDetailsImageLoadingError> {
            loadArtDetailsImageDataCalls += 1
            return loadArtDetailsImageDataClosure(url)
        }
    }

    var cancelables: [AnyCancellable] = []

    func makeSut(gateway: Gateway) -> CollectionInteractor {
        CollectionInteractor(gateway: gateway)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollection() {
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        _ = sut.loadCollection(page: 0, count: 0)

        XCTAssertTrue(gateway.loadCollectionCalled)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollectionPage() {
        let pageToLoad = 1
        var loadedPage: Int?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count in
            loadedPage = page
            return Empty().eraseToAnyPublisher()
        }
        let sut = makeSut(gateway: gateway)

        _ = sut.loadCollection(page: pageToLoad, count: 0)

        XCTAssertEqual(loadedPage, pageToLoad)
    }

    func test_collectionInteractor_onLoadCollection_tellsServiceToLoadCollectionPageSize() {
        let pageSizeToLoad = 1
        var loadedPageSize: Int?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count in
            loadedPageSize = count
            return Empty().eraseToAnyPublisher()
        }
        let sut = makeSut(gateway: gateway)

        _ = sut.loadCollection(page: 0, count: pageSizeToLoad)

        XCTAssertEqual(loadedPageSize, pageSizeToLoad)
    }

    func test_collectionInteractor_onLoadCollection_onSuccessGivesCollectionPage() {
        var collectionPageResult: CollectionPage?
        let page = 0
        let collectionInfo = CollectionInfo.mocked
        let collectionPage = CollectionPage(title: "Page \(page)", items: collectionInfo.collectionItems)
        let gateway = Gateway()
        gateway.loadCollectionClosure = { page, count in
            return Just(collectionInfo).setFailureType(to: CollectionLoadingError.self).eraseToAnyPublisher()
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollection(page: page, count: 3)
            .flatMap { Just<CollectionPage?>($0).eraseToAnyPublisher() }
            .catch { _ in Just<CollectionPage?>(nil).eraseToAnyPublisher() }
            .sink {
                collectionPageResult = $0
                expectation.fulfill()
            }
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(collectionPageResult, collectionPage)
    }

    func test_collectionInteractor_onLoadCollection_onFailureGivesError() {
        let error = ServiceLoadingError.invalidQuery
        var collectionPageResult: Subscribers.Completion<CollectionError>?
        let gateway = Gateway()
        gateway.loadCollectionClosure = { _, _ in
            Fail(error: .serviceError(error)).eraseToAnyPublisher()
        }
        let sut = makeSut(gateway: gateway)

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollection(page: 0, count: 3)
            .sink(receiveCompletion: { result in
                collectionPageResult = result
                expectation.fulfill()

            }, receiveValue: { _ in })
            .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(collectionPageResult, .failure(.loading(error: .serviceError(error))))
    }

    func test_loadCollectionItemImageData_onLoadImage_tellsServiceToLoadUrl() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage!.url!
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        _ = sut.loadCollectionItemImageData(from: url)

        XCTAssertTrue(gateway.loadCollectionImageDataCalled)
    }

    func test_loadCollectionItemImageData_onLoadImage_onSuccessGivesImageData() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage!.url!
        let imageData = Data(count: 2)
        var loadedImageResult: Data?
        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        gateway.loadCollectionImageDataClosure = { _ in
            Just(imageData).setFailureType(to: CollectionImageLoadingError.self).eraseToAnyPublisher()
        }

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url)
            .flatMap { Just<Data?>($0).eraseToAnyPublisher() }
            .catch { _ in Just<Data?>(nil).eraseToAnyPublisher() }
            .sink {
                loadedImageResult = $0
                expectation.fulfill()
            }
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, imageData)
    }

    func test_loadCollectionItemImageData_onLoadImage_onFailureGivesError() {
        let url = CollectionInfo.mocked.collectionItems.first!.webImage!.url!
        let error = ServiceLoadingError.invalidQuery
        var loadedImageResult: Subscribers.Completion<CollectionImageDataError>?

        let gateway = Gateway()
        let sut = makeSut(gateway: gateway)

        gateway.loadCollectionImageDataClosure = { _ in
            Fail(error: .serviceError(error)).eraseToAnyPublisher()
        }

        let expectation = XCTestExpectation(description: "\(#file) \(#function) \(#line)")
        sut.loadCollectionItemImageData(from: url)
            .sink(receiveCompletion: { result in
                loadedImageResult = result
                expectation.fulfill()

            }, receiveValue: { _ in })
            .store(in: &cancelables)
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(loadedImageResult, .failure(.loading(error: .serviceError(error))))
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

extension CollectionError: Equatable {
    public static func == (lhs: CollectionError, rhs: CollectionError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

extension CollectionImageDataError: Equatable {
    public static func == (lhs: CollectionImageDataError, rhs: CollectionImageDataError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

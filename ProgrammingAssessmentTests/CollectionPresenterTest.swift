//
//  CollectionPresenterTest.swift
//  CollectionPresenterTest
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import XCTest

@testable import ProgrammingAssessment
final class CollectionPresenterTest: XCTestCase {

    class View: CollectionView {

    }

    class Interactor: CollectionInteracting {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionPages: [Int] = []
        var loadCollectionCounts: [Int] = []
        var loadCollectionComplitions: [CollectionLoadingResult] = []
        func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResult){
            loadCollectionCalls += 1
            loadCollectionPages.append(page)
            loadCollectionCounts.append(count)
            loadCollectionComplitions.append(complition)
        }
    }

    func makeSut(view: CollectionView, interactor: CollectionInteracting, router: CollectionRouting? = nil) -> CollectionPresenter {
        let presenter = CollectionPresenter(view: view, interactor: interactor)
        presenter.router = router
        return presenter
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadCollection() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertTrue(interactor.loadCollectionCalled)
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadCollectionOnce() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(interactor.loadCollectionCalls, 1)
    }

    func test_collectionPresenter_onLoadCollection_tellsInteractorToLoadFirstPage() {
        let view = View()
        let interactor = Interactor()
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(interactor.loadCollectionPages.first, 0)
    }
    
}

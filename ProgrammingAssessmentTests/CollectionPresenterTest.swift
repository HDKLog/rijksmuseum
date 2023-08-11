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

        var configureCalled: Bool { configureCalls > 0 }
        var configureCalls: Int = 0
        var configureClosure: (CollectionViewModel) -> Void = {_ in }
        func configure(with model: CollectionViewModel) {
            configureCalls += 1
        }

        var updateCollectionCalled: Bool { updateCollectionCalls > 0 }
        var updateCollectionCalls: Int = 0
        func updateCollection() {
            updateCollectionCalls += 1
        }

    }

    class Interactor: CollectionInteracting {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        var loadCollectionClosure: ( Int, Int, CollectionLoadingResultHandler) -> Void = { _, _, _ in }
        func loadCollection(page: Int, count: Int, complition: @escaping CollectionLoadingResultHandler){
            loadCollectionCalls += 1
            loadCollectionClosure(page, count, complition)
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
        var loadedPage: Int?
        let view = View()
        let interactor = Interactor()
        interactor.loadCollectionClosure = { page, _, _ in loadedPage = page}
        let sut = makeSut(view: view, interactor: interactor)

        sut.loadCollection()

        XCTAssertEqual(loadedPage, 0)
    }
    
}

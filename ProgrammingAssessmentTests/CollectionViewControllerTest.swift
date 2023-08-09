//
//  CollectionViewControllerTest.swift
//  ProgrammingAssessmentTests
//
//  Created by Gari Sarkisyan on 09.08.23.
//

import XCTest

@testable import ProgrammingAssessment
final class CollectionViewControllerTest: XCTestCase {

    class Presenter: CollectionPresenting {

        var loadCollectionCalled: Bool { loadCollectionCalls > 0 }
        var loadCollectionCalls: Int = 0
        func loadCollection() {
            loadCollectionCalls += 1
        }
    }

    func makeSut(presenter: CollectionPresenting? = nil) -> CollectionViewController {
        let collectionView = CollectionViewController()
        collectionView.presenter = presenter
        return collectionView
    }

    func test_viewController_onViewDidLoad_tellsPresenterToLoadCollection() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()

        XCTAssertTrue(presenter.loadCollectionCalled)
    }

    func test_viewController_onViewDidLoad_tellsPresenterToLoadCollectionOnce() {
        let presenter = Presenter()
        let sut = makeSut(presenter: presenter)

        sut.loadViewIfNeeded()

        XCTAssertEqual(presenter.loadCollectionCalls, 1)
    }

}

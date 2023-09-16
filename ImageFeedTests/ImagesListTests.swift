//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Admin on 16.09.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    // 1 test
    func testPresenterViewDidLoadCalled() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        // when
        viewController.viewDidLoad()
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // 2 test
    func testEndlessLoop() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        var repeatCount = 0
        viewController.configure(presenter)
        // when
        repeat {
            presenter.endlessLoading(indexPath: IndexPath(row: -1, section: 0))
            repeatCount += 1
        } while (repeatCount <= 1000000)
        // then
        XCTAssertTrue(presenter.endlessLoading == 0)
    }
    
    // 3 test
    func testAlertForImagesListVC() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        // when
        presenter.showNetWorkErrorForImagesListVC(completion: { })
        // then
        XCTAssertTrue(presenter.model.title == "success")
    }
    
    

}

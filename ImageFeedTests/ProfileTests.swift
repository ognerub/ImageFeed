//
//  ProfileTests.swift
//  ProfileTests
//
//  Created by Admin on 14.09.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    // 1 test
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        // создаем объект-дублер презентера и соединяем его с вьюконтроллером
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        // when
        viewController.viewDidLoad()
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // 1 self-test
    func testPresenterCallLoadrequest() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter() // Dummy (пустышка)
        viewController.configure(presenter)
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(viewController.configureCalled)
    }
    
    // 2 test
    func personImageViewIsVisiableWhenViewWillAppear() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        // when
        presenter.viewWillAppear()
        // then
        XCTAssertTrue(presenter.personImageView.isHidden)
    }
    
    

}

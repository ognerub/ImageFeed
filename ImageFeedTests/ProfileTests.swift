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
    func testPresenterCallConfigureCell() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(viewController.configureCalled)
    }
    
    // 2 test
    func testPersonImageViewIsVisible() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertFalse(presenter.personImageView.isHidden)
    }
    
    // 3 test
    func testAlertIsShownWhenExitButtonPressed() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        // when
        presenter.showAlertBeforExit()
        // then
        XCTAssertTrue(presenter.showAlert)
    }
    
    // 4 test
    func testExitButtonCorrectImage() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertEqual(presenter.exitButton.tintColor, UIColor(named: "YP Red"))
    }
    
    // 5 test
    func testSwitchToSplashVC() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.configure(presenter)
        let window = UIApplication.shared.windows.first
        // when
        presenter.switchToSplashViewController()
        // then
        XCTAssertNoThrow(window!.rootViewController = SplashViewController())
    }
}

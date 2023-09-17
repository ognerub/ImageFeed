//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Admin on 9/17/23.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        // press auth button
        app.buttons["Authenticate"].tap()
        // wait for webview screen
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        // input user auth info
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("a.ulianovskiy@yandex.ru")
        webView.tap()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("'Q';h4e3a:v^Az&")
        webView.swipeUp()
        // press login button
        webView.buttons["Login"].tap()
        // wait for images feed screen
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // wait for images feed screen
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        // swipe up to scroll down
        firstCell.swipeUp()
        let secondCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
        secondCell.swipeDown()
        // like fist image
        firstCell.buttons["LikeButton"].tap()
        sleep(5)
        // unlike first image
        firstCell.buttons["LikeButton"].tap()
        sleep(5)
        // press on the first image
        firstCell.tap()
        sleep(3)
        // wait for fullscreen image open
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        // zoom in fullscreen image
        image.pinch(withScale: 3, velocity: 1)
        // zoomout fullscreen image
        image.pinch(withScale: 0.5, velocity: -1)
        // go back to the images feed screen
        app.scrollViews.buttons["BackButton"].tap()
        sleep(3)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        // wait for images feed screen
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        // go to profile screen
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(5)
        // check user info
        XCTAssertTrue(app.staticTexts["personNameLabel"].exists)
        XCTAssertTrue(app.staticTexts["personHashTagLabel"].exists)
        // press logout button
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(5)
        // wait for auth screen
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }
}

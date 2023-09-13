//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Admin on 13.09.2023.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    // 1 test
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        // создаем объект-дублер презентера и соединяем его с вьюконтроллером
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // 1 self-test
    func testPresenterCallLoadrequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper() // Dummy (пустышка)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    // 2 test
    func testProgeessVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    // 2 self-test
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    // 3 test
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        // when
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    // 3 self-test
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [
        URLQueryItem(name: "code", value: "test code")
        ]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        //when
        let resultCode = authHelper.code(from: url)
        //then
        XCTAssertEqual(resultCode, "test code")
    }
}

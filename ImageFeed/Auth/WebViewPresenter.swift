//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Admin on 13.09.2023.
//

import Foundation

/// протокол для рефакторинга - прописываем что может видеть MVC
protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    var delegate: WebViewViewControllerDelegate? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    /// переменная для рефакторинга - создаем переменную, которя соответствует протоколу MVC
    weak var view: WebViewViewControllerProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol, delegate: WebViewViewControllerDelegate?) {
        self.authHelper = authHelper
        self.delegate = delegate
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}

// MARK: - Items for tests
/// создаем объект-дублер для первого теста (1-test)
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var delegate: WebViewViewControllerDelegate?
    var viewDidLoadCalled: Bool = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func didUpdateProgressValue(_ newValue: Double) { }
    func code(from url: URL) -> String? { return nil }
}

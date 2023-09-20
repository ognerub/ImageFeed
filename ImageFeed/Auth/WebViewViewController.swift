//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Admin on 31.07.2023.
//

import UIKit
import WebKit

/// протокол для рефакторинга - прописываем что может видеть MVP
protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    private var alertPresenter: AlertPresenterProtocol?
    
    var presenter: WebViewPresenterProtocol?
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl(viewController: self)
        webView.navigationDelegate = self
        didUpdateProgressValue(0)
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self = self else { return }
                 self.didUpdateProgressValue(self.webView.estimatedProgress)
             })
    }
    
    /// функция для рефакторинга - загрузка webView по соответствующему запросу
    func load(request: URLRequest) {
        webView.load(request)
    }
    /// функция для рефакторинга - установка значения progressBar
    func setProgressValue(_ newValue: Float) {
        progressView.setProgress(newValue, animated: true)
    }
    /// функция для рефакторинга - скрытие progressBar
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    @IBAction func didTapNavBackButton(_ sender: Any) {
        presenter?.delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            presenter?.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if  let url = navigationAction.request.url{
            return presenter?.code(from: url)
        }
            return nil
        }
}

// MARK: - Items for tests
/// создаем объект-дублер для первого самостоятельного теста (1 self-test)
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    func setProgressValue(_ newValue: Float) { }
    func setProgressHidden(_ isHidden: Bool) { }
}

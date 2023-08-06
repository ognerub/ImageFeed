//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Admin on 31.07.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) // webViewViewController получил код
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) // пользователь нажал назад и отменил авторизацию
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        
        webView.navigationDelegate = self // делаем WebViewViewController навигационным делегатом для webView
        
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)! // инициализируем структуру URLComponents с указанием адреса запроса
        urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: AccessKey), // устанавливаем значение client_id - код доступа приложения
        URLQueryItem(name: "redirect_uri", value: RedirectURI), // устанавливаем redirect_URI - который обрабатывает успешную авторизацию пользователя
        URLQueryItem(name: "response_type", value: "code"), // устанавлваем тип ответа, который мы ожидаем, Unsplash ожидает от нас code
        URLQueryItem(name: "scope", value: AccessScope) // устанавливаем значение scope - списка доступов, разделенных плюсом
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    /// добавляем observer за текущим прогрессом загрузки WKWebView перед появлением WVVC
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    /// обязательно удаляем observer перед исчезновением WVVC
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    
    /// обработчик обновлений текущего прогресса загрузки WKWebVIew
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                updateProgress()
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    
    /// метод, мешяющий параметры отображения progressView в зависимости от прогресса загрузки WKWebView
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    @IBAction func didTapNavBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            // TODO: process code
            // оставили комментарий чтобы в дальнейшем здесь обработать полученный код
            decisionHandler(.cancel) // если код успешно получен, отменяем навигационное действие (все, что нужно от webView мы получили)
        } else {
            decisionHandler(.allow) // если код не получен, разрешаем навигационное действие (возможно пользователь переходит на новую страницу в рамках процесса авторизации)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url, // получаем URL из навигационного действия navigationAction
            let urlComponents = URLComponents(string: url.absoluteString), // создаем структуру URLComponents только теперь получаем компонены из URL, а не формируем URL
            urlComponents.path == "/oauth/authorize/native", // проверяем совпадает ли адрес запроса с адресом получания кода
            let items = urlComponents.queryItems, // проверяем есть ли в urlComponents компоненты запроса (URLQueryItem - это структура, которая содержит имя компонента name и его значение value)
            let codeItem = items.first(where: { $0.name == "code" }) // ищем в массиве компонентов такой, у которого значение == code
        {
            return codeItem.value // возвращаем значение если все успешно
        } else {
            return nil
        }
    }
}

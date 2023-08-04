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
    @IBOutlet private var WebView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        
        WebView.navigationDelegate = self // делаем WebViewViewController навигационным делегатом для webView
        
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)! // инициализируем структуру URLComponents с указанием адреса запроса
        urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: AccessKey), // устанавливаем значение client_id - код доступа приложения
        URLQueryItem(name: "redirect_uri", value: RedirectURI), // устанавливаем redirect_URI - который обрабатывает успешную авторизацию пользователя
        URLQueryItem(name: "response_type", value: "code"), // устанавлваем тип ответа, который мы ожидаем, Unsplash ожидает от нас code
        URLQueryItem(name: "scope", value: AccessScope) // устанавливаем значение scope - списка доступов, разделенных плюсом
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        WebView.load(request)
        
        
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
            urlComponents.path == "/oauth/authorize/native", // проверяем совпадаем ли адрес запроса с адресом получания кода
            let items = urlComponents.queryItems, // проверяем есть ли в urlComponents компоненты запроса (URLQueryItem - это структура, которая содержит имя компонента name и его значение value)
            let codeItem = items.first(where: { $0.name == "code" }) // ищем в массиве компонентов такой, у которого значение == code
        {
            return codeItem.value // возвращаем значение если все успешно
        } else {
            return nil
        }
    }
}

//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Admin on 31.07.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewIdentifier: String = "ShowWebView"
    private var oAuth2Service = OAuth2Service()
    private var oAuth2TokenStorage = OAuth2TokenStorage()
    private var splashViewController = SplashViewController()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                fatalError("Failed to prepare \(showWebViewIdentifier)")
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper, delegate: self)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
        } else {
            super.prepare(for: segue, sender: sender) // 6
        }
    }
}

// MARK: - WebViewViewController Delegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

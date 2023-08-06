//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Admin on 31.07.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    
    
    private let showWebViewIdentifier: String = "ShowWebView"
    
    private var oAuth2Service = OAuth2Service()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewIdentifier {
            guard
                let webViewController = segue.destination as? WebViewViewController else { fatalError("Failed to prepare \(showWebViewIdentifier)") }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender) // 6
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service.fetchOAuthToken(code, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body
                self.oAuth2Service.authToken = authToken
            case .failure(let error):
                print("Result is \(result)")
                print("error! \(error)")
            }
        }
        )
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

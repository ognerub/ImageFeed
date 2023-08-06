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
    private var oAuth2TokenStorage = OAuth2TokenStorage()
    
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
        print("Old token was: \(self.oAuth2TokenStorage.token)")
        oAuth2Service.fetchOAuthToken(code, completion: { result in
            switch result {
            case .success(let result):
                print("We`ve got new token! \(result)")
            case .failure(let error):
                print("We`ve got error! \(error)")
            }
        }
        )
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

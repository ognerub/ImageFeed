//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Admin on 31.07.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let ShowWebViewIdentifier: String = "ShowWebView"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewIdentifier {
            guard
                let webViewController = segue.destination as? WebViewViewController else { fatalError("Failed to prepare \(ShowWebViewIdentifier)") }
            webViewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender) // 6
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // TODO: next lesson
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

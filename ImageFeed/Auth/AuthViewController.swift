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
    
    private let showWebViewIdentifier: String = "ShowWebView"
    private var oAuth2Service = OAuth2Service()
    private var oAuth2TokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("AuthVC viewWillAppear")
        print("viewWillAppera ErrorVar is \(String(describing: oAuth2Service.errorVar))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //alertPresenter = AlertPresenterImpl(viewController: self)
        
        print("viewDidApear ErrorVar is \(String(describing: oAuth2Service.errorVar))")
            
            
//                let alert = UIAlertController(title: "Alert!", message: "No message", preferredStyle: .alert)
//                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alert.addAction(action)
//                self.present(alert, animated: true, completion: {
//                    self.oAuth2Service.errorVar = nil
//                })
            
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("AuthVC starts prepare")
        if segue.identifier == showWebViewIdentifier {
            guard
                let webViewController = segue.destination as? WebViewViewController
            else {
                fatalError("Failed to prepare \(showWebViewIdentifier)")
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender) // 6
        }
        print("AuthVC end prepare func")
    }
    
    
    func showNetWorkErrorForSpashVC(_ vc: UIViewController) {
    
        
        let alert = UIAlertController(title: "Alert!", message: "No message", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(action)
                        vc.present(alert, animated: true, completion: {
                            //self.oAuth2Service.errorVar = nil
                        })
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

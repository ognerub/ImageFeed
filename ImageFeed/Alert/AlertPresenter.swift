//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Admin on 21.08.2023.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func show(with alertModel: AlertModel)
}

final class AlertPresenterImpl {
    private weak var viewController: UIViewController?
    
    var topVC: UIViewController {
        var topController: UIViewController = UIApplication.shared.mainKeyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

}

extension AlertPresenterImpl: AlertPresenterProtocol {
    func show(with alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        topVC.present(alert, animated: true)
        //viewController?.presentedViewController?.present(alert, animated: true)
    }
}

extension UIApplication {
    var mainKeyWindow: UIWindow? {
        get {
            if #available(iOS 13, *) {
                return connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .first { $0.isKeyWindow }
            } else {
                return keyWindow
            }
        }
    }
}

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
        let firstAction = UIAlertAction(
            title: alertModel.firstButton,
            style: .default) { _ in
            alertModel.firstCompletion()
        }
        alert.addAction(firstAction)
        if alertModel.secondButton != nil {
            let secondAction = UIAlertAction(
                title: alertModel.secondButton,
                style: .default) { _ in
                    alertModel.secondCompletion()
                }
            alert.addAction(secondAction)
        }
        topVC.present(alert, animated: true)
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

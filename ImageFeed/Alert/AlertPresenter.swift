//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Admin on 21.08.2023.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func show(with alertModel: AlertModel)
    func show2(with alertModel: AlertModel2)
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
    
    func show2(with alertModel: AlertModel2) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action1 = UIAlertAction(
            title: alertModel.buttonText1,
            style: .default) { _ in
            alertModel.completion1()
        }
        let action2 = UIAlertAction(
            title: alertModel.buttonText2,
            style: .default) { _ in
            alertModel.completion2()
        }
        alert.addAction(action1)
        alert.addAction(action2)
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

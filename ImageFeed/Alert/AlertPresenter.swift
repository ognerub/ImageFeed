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
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

}

extension AlertPresenterImpl: AlertPresenterProtocol {
   
    func show(with alertModel: AlertModel) {
        DispatchQueue.main.async {
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
            self.viewController?.present(alert,
                                    animated: true)
        }
       
    }
}

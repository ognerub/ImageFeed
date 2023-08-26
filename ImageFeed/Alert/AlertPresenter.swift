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

final class AlertPresenter {
    
    weak var delegate: UIViewController?
    
    func show(with alertModel: AlertModel, completion: @escaping () -> Void) {
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
                completion()
            }
        alert.addAction(action)
        viewController?.presentedViewController?.present(alert,
                                animated: true)
    }
}


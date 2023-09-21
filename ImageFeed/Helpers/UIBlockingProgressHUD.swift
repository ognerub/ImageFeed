//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Admin on 14.08.2023.
//

import UIKit
import ProgressHUD
import Kingfisher

final class UIBlockingProgressHUD {
    
    struct MyIndicator: Indicator {
        var image: UIImage = UIImage()
        var imageView: UIImageView = UIImageView()
        let view: UIView = UIView()
        func startAnimatingView() { view.isHidden = false }
        func stopAnimatingView() { view.isHidden = true }
        init() {
            image = UIImage(named: "Stub")!
            imageView = UIImageView(image: image)
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -image.size.height/2).isActive = true
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -image.size.width/2).isActive = true
            view.contentMode = UIView.ContentMode.center
            view.backgroundColor = UIColor(named: "YP Grey")
        }
    }
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

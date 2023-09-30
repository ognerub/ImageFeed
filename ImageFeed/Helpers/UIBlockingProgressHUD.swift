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
    
    func addStubImageView(view: UIView, stubImageView: UIImageView) {
        
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = false
        
        let image = UIBlockingProgressHUD.MyIndicator().image
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 166, height: 150)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 1, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 0.75
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        stubImageView.layer.addSublayer(gradient)
        view.addSubview(stubImageView)
        
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 166),
            stubImageView.heightAnchor.constraint(equalToConstant: 150),
            stubImageView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            stubImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant:  -83)])

        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 166, height: 150))
        maskView.layer.contents = image.cgImage
        stubImageView.mask = maskView
    }
    
    func removeStubImageView(stubImageView: UIImageView) {
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = true
        stubImageView.removeFromSuperview()
    }
    
}

//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Admin on 18.07.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {    
    
    static let shared = SingleImageViewController()
    
    private var alertPresenter: AlertPresenterProtocol?
    
    var fullscreenImageURL: URL?
    
    var stubImageView: UIImageView = {
        let stubImageView = UIImageView()
        stubImageView.backgroundColor = .clear
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertPresenter = AlertPresenterImpl(viewController: self)
        loadFullscreenImage(imageView: singleImageView)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image: UIImage = singleImageView.image else { return }
        let scaleImageRatio = AuthConfiguration.standart.scaledWidth / image.size.width
        let item: [Any] = [image.scalePreservingAspectRatio(targetSizeScale: scaleImageRatio)]
        let ac = UIActivityViewController(activityItems: item, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
    
    /// метод, который вызывается после завершения зума пользователем (для способа 2)
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.rescaleAndCenterImageInScrollView(image: self.singleImageView.image!)
        }
    }
}

// MARK: - Private functions
private extension SingleImageViewController {
    
    func addStubImageView(view: UIView, stubImageView: UIImageView) {
        let image = UIBlockingProgressHUD.MyIndicator().image
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 166, height: 150)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
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
            stubImageView.topAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -75),
            stubImageView.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant:  -83)])

        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 166, height: 150))
        maskView.layer.contents = image.cgImage
        stubImageView.mask = maskView
    }
    
    func loadFullscreenImage(imageView: UIImageView) {
        addStubImageView(view: view, stubImageView: stubImageView)
        guard let fullscreenImageURL = fullscreenImageURL else { return }
        imageView.kf.setImage(with: fullscreenImageURL) { result in
            switch result {
            case .success(let result):
                self.stubImageView.removeFromSuperview()
                self.rescaleAndCenterImageInScrollView(image: result.image)
            case .failure(let error):
                self.showNetWorkErrorForSingleImageVC {
                    self.loadFullscreenImage(imageView: imageView)
                }
                print("Error while retrieveImage \(error)")
            }
        }
    }
    
    func showNetWorkErrorForSingleImageVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Попробовать еще раз?",
                firstButton: "Повторить",
                secondButton: "Не надо",
                firstCompletion: completion,
                secondCompletion: {})
            self.alertPresenter?.show(with: model)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

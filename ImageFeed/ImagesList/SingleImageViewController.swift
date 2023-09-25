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
    
    private var stubImageView: UIImageView = {
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
        setupGestureRecognizer()
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
    
    func loadFullscreenImage(imageView: UIImageView) {
        UIBlockingProgressHUD().addStubImageView(view: view, stubImageView: stubImageView)
        guard let fullscreenImageURL = fullscreenImageURL else { return }
        imageView.kf.setImage(with: fullscreenImageURL) { result in
            switch result {
            case .success(let result):
                UIBlockingProgressHUD().removeStubImageView(stubImageView: self.stubImageView)
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

// MARK: - UIGestureRecognizer
extension SingleImageViewController {
    func  setupGestureRecognizer() {
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipe(_:))
            )
        swipeGestureRecognizerDown.direction = .down
        scrollView.addGestureRecognizer(swipeGestureRecognizerDown)
    }
    
    @objc
    func didSwipe(_ sender: UIGestureRecognizer) {
        dismiss(animated: true)
    }
}

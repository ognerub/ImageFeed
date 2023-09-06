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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateFullscreenImage(image: UIImage(named: "Stub")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertPresenter = AlertPresenterImpl(viewController: self)
        loadFullscreenImage()
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let item = [singleImageView.image]
        let ac = UIActivityViewController(activityItems: item as [Any], applicationActivities: nil)
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
            //self.rescaleAndCenterImageInScrollViewV2()
            self.rescaleAndCenterImageInScrollView(image: self.singleImageView.image!)
        }
    }
}

// MARK: - Private functions
private extension SingleImageViewController {
    
    func updateFullscreenImage(image: UIImage) {
        singleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    func loadFullscreenImage() {
        UIBlockingProgressHUD.show()
        guard let fullscreenImageURL = fullscreenImageURL else { return }
        let resourse = KF.ImageResource(downloadURL: fullscreenImageURL)
        KingfisherManager.shared.retrieveImage(with: resourse) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let result):
                self.updateFullscreenImage(image: result.image)
            case .failure(let error):
                self.showNetWorkErrorForSingleImageVC {
                    self.loadFullscreenImage()
                }
                print("Error while retrieveImage \(error)")
            }
        }
    }
    
    func showNetWorkErrorForSingleImageVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model2 = AlertModel2(
                title: "Что-то пошло не так(",
                message: "Попробовать еще раз?",
                buttonText1: "Повторить",
                buttonText2: "Не надо",
                completion1: completion,
                completion2: {})
            self.alertPresenter?.show2(with: model2)
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

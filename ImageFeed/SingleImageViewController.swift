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
    
    static let DidChangeNotification = Notification.Name(rawValue: "SingleImageProviderDidChange")
    
    private var singleImageServiceObserver: NSObjectProtocol?
    
    var image = UIImage(named: "Stub")!
    var fullscreenImageURL: URL?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateFullscreenImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        singleImageServiceObserver = NotificationCenter.default.addObserver(
            forName: SingleImageViewController.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateFullscreenImageObjc(notification: notification)
        }
    }
    
    @objc
    private func updateFullscreenImageObjc(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let fullscreenImage = userInfo["FullscreenImage"] as? UIImage
        else { return }
        image = fullscreenImage
        updateFullscreenImage()
    }
    
    func updateFullscreenImage() {
        singleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    func loadFullscreenImage() {
        UIBlockingProgressHUD.show()
        guard let fullscreenImageURL = fullscreenImageURL else {
            print("FullscreenImage is empty")
            return
        }
        let resourse = KF.ImageResource(downloadURL: fullscreenImageURL)
        KingfisherManager.shared.retrieveImage(with: resourse) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let result):
                NotificationCenter.default.post(
                    name: SingleImageViewController.DidChangeNotification,
                    object: self,
                    userInfo: ["FullscreenImage": result.image]
                )
            case .failure(let error):
                //self.showNetWorkErrorForImagesListVC() { self.loadFullscreenImage(indexPath: indexPath) }
                print("Error while retrieveImage \(error)")
            }
        }
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let item = [image]
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
            self.rescaleAndCenterImageInScrollView(image: self.image)
        }
    }
}

extension SingleImageViewController {
    
//    /// способ 2 позиционирования картинки (из вебинара с Дмитрием Исаевым)
//    private func rescaleAndCenterImageInScrollViewV2() {
//        let halfWidth = (scrollView.bounds.size.width - singleImageView.frame.size.width) / 2
//        let halfHeight = (scrollView.bounds.size.height - singleImageView.frame.size.height) / 2
//        scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
//    }
    
    /// способ 1 позиционирования картирки из учебника
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

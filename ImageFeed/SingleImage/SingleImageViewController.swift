//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Admin on 18.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else {return}
            singleImageView.image = image
            rescaleAndCenterImageInScrollViewV2()
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    /// в этом методе выставляем позицию картинки после расположения всех subview (для способа 2)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rescaleAndCenterImageInScrollViewV2()
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
            self.rescaleAndCenterImageInScrollViewV2()
        }
    }
}

extension SingleImageViewController {
    
    
    /// способ 2 позиционирования картинки (из вебинара с Дмитрием Исаевым)
    private func rescaleAndCenterImageInScrollViewV2() {
        let halfWidth = (scrollView.bounds.size.width - singleImageView.frame.size.width) / 2
        let halfHeight = (scrollView.bounds.size.height - singleImageView.frame.size.height) / 2
        scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
    }
    
    /// способ 1 позиционирования картинки (из учебника)
    //    private func rescaleAndCenterImageInScrollView(image: UIImage) {
    //        let minZoomScale = scrollView.minimumZoomScale
    //        let maxZoomScale = scrollView.maximumZoomScale
    //        view.layoutIfNeeded()
    //        let visibleRectSize = scrollView.bounds.size
    //        let imageSize = image.size
    //        let hScale = visibleRectSize.width / imageSize.width
    //        let vScale = visibleRectSize.height / imageSize.height
    //        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
    //        scrollView.setZoomScale(scale, animated: false)
    //        scrollView.layoutIfNeeded()
    //        let newContentSize = scrollView.contentSize
    //        let x = (newContentSize.width - visibleRectSize.width) / 2
    //        let y = (newContentSize.width - visibleRectSize.height) / 2
    //        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    //    }
}

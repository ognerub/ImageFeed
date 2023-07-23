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
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let item = [image]
        let ac = UIActivityViewController(activityItems: item, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}

extension SingleImageViewController {
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
        let y = (newContentSize.width - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

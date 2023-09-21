//
//  ScaledImage.swift
//  ImageFeed
//
//  Created by Admin on 9/21/23.
//

import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSizeScale: Double) -> UIImage {
        let scaledImageSize = CGSize(
            width: size.width * targetSizeScale,
            height: size.height * targetSizeScale)
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
}

//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Admin on 06.07.2023.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
           
    override func prepareForReuse() {
        super.prepareForReuse()
        // отменяем загрузку чтобы избежать багов
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        print("Like button clicked")
        delegate?.imageListCellDidTapLike(self)
    }
    
}

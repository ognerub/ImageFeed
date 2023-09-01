//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Admin on 06.07.2023.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell" 
    
    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
           
    override func prepareForReuse() {
        super.prepareForReuse()
        // отменяем загрузку чтобы избежать багов
        cellImage.kf.cancelDownloadTask()
    }
}

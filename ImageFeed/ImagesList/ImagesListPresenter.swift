//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Admin on 14.09.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {
    var viewController: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func endlessLoading(indexPath: IndexPath)
    func updateTableViewAnimated()
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void)
    func configCellContent(for cell: ImagesListCell)
    func configCellHeight(indexPath: IndexPath) -> CGFloat
    func changeCellLike(for cell: ImagesListCell)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    private let imagesListService = ImagesListService.shared
    
    weak var viewController: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewController?.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        fetchPhotosNextPageSimple()
    }
    
    private func fetchPhotosNextPageSimple() {
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.fetchPhotosNextPageSimple()
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    func endlessLoading(indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            fetchPhotosNextPageSimple()
        }
    }
    
    func updateTableViewAnimated() {
        guard
            let photos = viewController?.photos,
            let tableView = viewController?.tableView
        else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        viewController?.photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount ..< newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in}
        }
    }
    
    func configCellHeight(indexPath: IndexPath) -> CGFloat {
        guard
            let photos = viewController?.photos,
            let tableView = viewController?.tableView
        else { return CGFloat(50)}
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        if photos[indexPath.row].size.height > 50 {
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = photos[indexPath.row].size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        } else {
            let cellHeight = 50 + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }
    
    func configCellContent(for cell: ImagesListCell) {
        // set photos for each cell
        guard
            let image = UIImage(named: "Stub"),
            let photos = viewController?.photos,
            let indexPath = viewController?.tableView.indexPath(for: cell)
        else { return }
        configCellImage(for: cell, with: indexPath, photos: photos, image: image)
        // set text (date) for each cell
        cell.cellDateLabel.text = photos[indexPath.row].createdAt ?? ""
        // set like status for each cell
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
    
    private func configCellImage(for cell: ImagesListCell, with indexPath: IndexPath, photos: [Photo], image: UIImage) {
        cell.cellImage.kf.indicatorType = .custom(indicator: UIBlockingProgressHUD.MyIndicator())
        cell.cellImage.kf.setImage(with: URL(string:photos[indexPath.row].thumbImageURL)) { result in
            switch result {
            case .success(_):
                cell.cellImage.contentMode = UIView.ContentMode.scaleAspectFit
                self.viewController?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                cell.cellImage.contentMode = UIView.ContentMode.center
                cell.cellImage.backgroundColor = UIColor(named: "YP Grey")
                cell.cellImage.image = image
            }
        }
    }
    
    func changeCellLike(for cell: ImagesListCell) {
        guard
            let photos = viewController?.photos,
            let indexPath = viewController?.tableView.indexPath(for: cell)
        else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.viewController?.photos = self.imagesListService.photos
                guard let isLiked = self.viewController?.photos[indexPath.row].isLiked else { return }
                let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
                cell.cellLikeButton.setImage(likeImage, for: .normal)
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.changeCellLike(for: cell)
                }
            }
        }
    }
    
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Попробовать еще раз?",
                firstButton: "Повторить",
                secondButton: "Не надо",
                firstCompletion: completion,
                secondCompletion: {})
            self.viewController?.alertPresenter?.show(with: model)
        }
    }
}

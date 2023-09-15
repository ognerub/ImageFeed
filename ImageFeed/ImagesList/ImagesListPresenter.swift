//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Admin on 14.09.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {
    var viewController: ImagesListViewControllerProtocol? { get set }
    func fetchPhotosNextPageSimple()
    func updateTableViewAnimated()
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void)
    func configCell(for cell: ImagesListCell)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    private let imagesListService = ImagesListService.shared
    
    weak var viewController: ImagesListViewControllerProtocol?
    
    func fetchPhotosNextPageSimple() {
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
    
    func updateTableViewAnimated() {
        guard let photos = viewController?.photos else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        viewController?.photos = imagesListService.photos
        if oldCount != newCount {
            viewController?.tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount ..< newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                viewController?.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in}
        }
    }
    
    func configCell(for cell: ImagesListCell) {
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

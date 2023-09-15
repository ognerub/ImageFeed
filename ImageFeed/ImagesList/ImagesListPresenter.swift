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
        guard let oldCount = viewController?.photos.count else { return }
        let newCount = imagesListService.photos.count
        viewController?.photos = imagesListService.photos
        if oldCount != newCount {
            viewController?.tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                viewController?.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in}
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

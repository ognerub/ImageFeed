//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Admin on 14.09.2023.
//

import UIKit
import Kingfisher

protocol ImagesListPresenterProtocol {
    var viewController: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func endlessLoading(indexPath: IndexPath)
    func updateTableViewAnimated()
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var cellHeightArray: [CGFloat?] = []
    weak var viewController: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        viewController?.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        fetchPhotosNextPageSimple()
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
    
    private func fetchPhotosNextPageSimple() {
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage() { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                return
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.fetchPhotosNextPageSimple()
                }
            }
        }
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    private let imagesListService = ImagesListService.shared
    
    var viewController: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var endlessLoading: Int = 0
    var model = AlertModel(title: "test", message: "test", firstButton: "test", secondButton: nil, firstCompletion: {}, secondCompletion: {})
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func endlessLoading(indexPath: IndexPath) {
        endlessLoading = 1
        if indexPath.row + 1 == imagesListService.photos.count {
            endlessLoading = 0
        }
    }
    func updateTableViewAnimated() { }
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void) {
        model.title = "success"
        viewController?.alertPresenter?.show(with: model)
    }
}

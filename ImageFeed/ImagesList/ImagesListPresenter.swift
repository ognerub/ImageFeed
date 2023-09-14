//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Admin on 14.09.2023.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var viewController: ImagesListViewControllerProtocol? { get set }
    func fetchPhotosNextPageSimple()
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
                self.viewController?.showNetWorkErrorForImagesListVC() {
                    self.fetchPhotosNextPageSimple()
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

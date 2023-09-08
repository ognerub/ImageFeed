//
//  ViewController.swift
//  ImageFeed
//
//  Created by Admin on 01.07.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSequeIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private let singleImageViewController = SingleImageViewController.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        fetchPhotosNextPageSimple()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertPresenter = AlertPresenterImpl(viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSequeIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController.fullscreenImageURL = URL(string: photos[indexPath.row].largeImageURL)
//            _ = viewController.view // crash fix
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    /// в данном методе будем настраивать реагирование на нажатие пользователем на ячейку (строку)
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: self.showSingleImageSequeIdentifier, sender: indexPath)
        }
    
    /// добавлен новый метод, корректирующий высоту ячейки (строки) в зависимости от высоты изображения
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            if indexPath.row + 1 == imagesListService.photos.count {
                fetchPhotosNextPageSimple()
            }
        }
}

// MARK: - Private extension
private extension ImagesListViewController {
    
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
    
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Попробовать еще раз?",
                firstButton: "Повторить",
                secondButton: "Не надо",
                firstCompletion: completion,
                secondCompletion: {})
            self.alertPresenter?.show(with: model)
        }
    }
    
    /// данный метод конфигурирует стиль кастомных ячеек, в частности присваивается картинка, если такая имеется (если нет, guard else вернет nil), форматируется дата, задается стиль кнопки лайка для четных и нечетных ячеек по indexPath.row)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        /// осуществляем загрузку фото, пока идет загрузка или фото отсутствует вставляем заглушку
        guard let image = UIImage(named: "Stub"),
              let data = image.pngData() else { return }
        cell.cellImage.kf.indicatorType = .image(imageData: data)
        cell.cellImage.kf.setImage(with: URL(string:photos[indexPath.row].thumbImageURL)) { result in
            switch result {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("Error to load images at row \(indexPath.row). \n \(error)")
            }
        }
        
        cell.cellDateLabel.text = photos[indexPath.row].createdAt?.dateTimeString ?? ""
        
        /// настраиваем лайки для каждой фотографии
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
}

//MARK: - ImageListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let isLiked = self.photos[indexPath.row].isLiked
                let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
                cell.cellLikeButton.setImage(likeImage, for: .normal)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.imageListCellDidTapLike(cell)
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    /// данный метод устанавливает количество строк (в нашем случае кастомных ячеек) в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    /// данный метод опредетяет какую ячейку выводить, если нет кастомной, то отработает quard else и отобразится стандартная ячейка. Также запускается метод из extension для MVC - configCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in}
        }
    }
}


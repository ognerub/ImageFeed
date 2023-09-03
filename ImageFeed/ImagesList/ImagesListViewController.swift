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
    
    var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    } ()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        // connection of tableViw with it`s delegate and dataSource (now it`s MVC two in one) in code:
        //        tableView.delegate = self
        //        tableView.dataSource = self
        //        // custom cell registration:
        //        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case .success(_):
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Error from viewDidload \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSequeIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            viewController.image = self.singleImageViewController.image
//            let indexPath = sender as! IndexPath
//            _ = viewController.view // crash fix
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Extensions
extension ImagesListViewController {
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
        
        /// устанавливаем верную дату для каждой фотографии
        var date = photos[indexPath.row].createdAt ?? "no date"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let formattedDate = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "ru_Ru")
            cell.cellDateLabel.text = "\(dateFormatter.string(from: formattedDate))"
        } else {
            cell.cellDateLabel.text = "no date of photo"
        }
        
        /// настраиваем лайки для каждой фотографии
        
        
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
}

//MARK: - ImageListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
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
        cell.delegate = self
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
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

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    /// в данном методе будем настраивать реагирование на нажатие пользователем на ячейку (строку)
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            UIBlockingProgressHUD.show()
            guard let url = URL(string:photos[indexPath.row].largeImageURL) else {
                print("Guard, no fullsize image url!")
                return
            }
            let resourse = KF.ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resourse) { result in
                switch result {
                case .success(let result):
                    self.singleImageViewController.image = result.image
                    UIBlockingProgressHUD.dismiss()
                    self.performSegue(withIdentifier: self.showSingleImageSequeIdentifier, sender: indexPath)
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("Error while retrieveImage \(error)")
                }
            }
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
                imagesListService.fetchPhotosNextPage() { _ in}
            }
        }
}


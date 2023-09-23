//
//  ViewController.swift
//  ImageFeed
//
//  Created by Admin on 01.07.2023.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol! { get set }
    var alertPresenter: AlertPresenterProtocol? { get set }
    var photos: [Photo] { get set }
    var tableView: UITableView! { get set }
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var alertPresenter: AlertPresenterProtocol?
    var presenter: ImagesListPresenterProtocol!
    var photos: [Photo] = []
    
    @IBOutlet var tableView: UITableView!
    
    private let showSingleImageSequeIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func loadView() {
        super.loadView()
        presenter = ImagesListPresenter()
        alertPresenter = AlertPresenterImpl(viewController: self)
        configure(presenter)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.presenter.updateTableViewAnimated()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSequeIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController.fullscreenImageURL = URL(string: photos[indexPath.row].largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter.viewController = self
    }
    
    private func configCell(at indexPath: IndexPath, cell: CellViewModel) {
        let items = CellViewModel(
            cellImage: cell.cellImage,
            cellDateLabel: cell.cellDateLabel,
            cellLikeButton: cell.cellLikeButton)
        guard let image = UIImage(named: "Stub") else { return}
        items.cellImage.kf.indicatorType = .custom(indicator: UIBlockingProgressHUD.MyIndicator())
        items.cellImage.kf.setImage(with: URL(string:photos[indexPath.row].thumbImageURL)) { result in
            switch result {
            case .success(_):
                items.cellImage.contentMode = UIView.ContentMode.scaleAspectFill
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                items.cellImage.contentMode = UIView.ContentMode.center
                items.cellImage.backgroundColor = UIColor(named: "YP Grey")
                items.cellImage.image = image
            }
        }
        items.cellDateLabel.text = photos[indexPath.row].createdAt ?? ""
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        items.cellLikeButton.accessibilityIdentifier = "LikeButton"
        items.cellLikeButton.setImage(likeImage, for: .normal)
    }
    
    private func changeCellLike(for cell: ImagesListCell) {
        cellLikeAnimation(for: cell)
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            cell.cellLikeButton.layer.removeAllAnimations()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let isLiked = self.photos[indexPath.row].isLiked
                let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
                cell.cellLikeButton.setImage(likeImage, for: .normal)
            case .failure:
                self.presenter.showNetWorkErrorForImagesListVC() {
                    self.changeCellLike(for: cell)
                }
            }
        }
    }
    
    private func cellLikeAnimation(for cell: ImagesListCell) {
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .repeat) {
            for startTime in 0..<2 {
                UIView.addKeyframe(withRelativeStartTime: 0 + Double(startTime) / 10, relativeDuration: 0.1) {
                    cell.cellLikeButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.1 + Double(startTime) / 10, relativeDuration: 0.1) {
                    cell.cellLikeButton.transform = .identity
                }
            }
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
            return UITableView.automaticDimension
        }
    /// данный метод осуществляет запуск загрузки фотографий в случае если текущая строка + 1 равна количеству фотографий в массии (тем самым реализуем предварительную загрузку, не позволив пролистать пользователю ленту до последней фотографии, получаем бесконечную ленту!)
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            presenter.endlessLoading(indexPath: indexPath)
        }
}

//MARK: - ImageListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    /// вызываем запрос в сеть со сменой текущего состояния лайка, на время запроса блокируем интерфейс
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        changeCellLike(for: cell)
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
        let cellViewModel = CellViewModel(
            cellImage: imageListCell.cellImage,
            cellDateLabel: imageListCell.cellDateLabel,
            cellLikeButton: imageListCell.cellLikeButton)
        configCell(at: indexPath, cell: cellViewModel)
        return imageListCell
    }
}


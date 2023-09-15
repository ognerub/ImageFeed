//
//  ViewController.swift
//  ImageFeed
//
//  Created by Admin on 01.07.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol! { get set }
    var alertPresenter: AlertPresenterProtocol? { get set }
    var photos: [Photo] { get set }
    var tableView: UITableView! { get set }
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    private let showSingleImageSequeIdentifier = "ShowSingleImage"
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var alertPresenter: AlertPresenterProtocol?
    var presenter: ImagesListPresenterProtocol!
    var photos: [Photo] = []
    
    @IBOutlet var tableView: UITableView!
    
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
            presenter.configCellHeight(indexPath: indexPath)
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
        presenter.changeCellLike(for: cell)
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
        presenter.configCellContent(for: imageListCell)
        return imageListCell
    }
}


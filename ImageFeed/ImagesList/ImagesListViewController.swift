//
//  ViewController.swift
//  ImageFeed
//
//  Created by Admin on 01.07.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let ShowSingleImageSequeIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSequeIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let image = UIImage(named: photosName[indexPath.row])
            //_ = viewController.view // crash fixed
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    /// данный метод устанавливает количество строк (в нашем случае кастомных ячеек) в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    /// данный метод опредетяет какую ячейку выводить, если нет кастомной, то отработает quard else и отобразится стандартная ячейка. Также запускается метод из extension для MVC - configCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    /// данный метод конфигурирует стиль кастомных ячеек, в частности присваивается картинка, если такая имеется (если нет, guard else вернет nil), форматируется дата, задается стиль кнопки лайка для четных и нечетных ячеек по indexPath.row)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cellImage.image = image
        cell.cellDateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    /// в данном методе будем настраивать реагирование на нажатие пользователем на ячейку (строку)
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: ShowSingleImageSequeIdentifier, sender: indexPath)
            
        }
    
    /// добавлен новый метод, корректирующий высоту ячейки (строки) в зависимости от высоты изображения
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let image = UIImage(named: photosName[indexPath.row]) else {
                return 0
            }
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
//            imagesListService.fetchPhotosNextPage() { result in
//                switch result {
//                case .success(let result):
//                    var value = 0
//                    for item in result {
//                        value += 1
//                        print("\(value).Success result is \(item)")
//                    }
//                    print("We have now \(self.imagesListService.photos.count) photos")
//                case .failure(let error):
//                    print("Error is \(error)")
//                }
//            }
//            if indexPath.row + 1 == imagesListService.photos.count {
//                print("We have now \(imagesListService.photos.count) photos")
//                imagesListService.fetchPhotosNextPage() {_ in }
//            }
        }
}


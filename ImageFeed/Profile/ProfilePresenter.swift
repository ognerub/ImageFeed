//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Admin on 13.09.2023.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
}

final class ProfilePresenter {
    var view: ProfileViewControllerProtocol?
}

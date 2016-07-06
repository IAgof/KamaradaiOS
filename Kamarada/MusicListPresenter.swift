//
//  MusicListPresenter.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import AVFoundation

class MusicListPresenter: NSObject,MusicListPresenterInterface,MusicInteractorDelegate {
    //MARK: - VIPER
    var wireframe: MusicListWireframe?
    var controller: MusicViewInterface?
    var interactor: MusicListInteractorInterface?
    var delegate:MusicPresenterDelegate?
    
    //MARK: - Interface
    func pushBack(){
        wireframe?.goPrevController()
    }

    func viewDidLoad() {
        controller?.initVariables()
        
        interactor?.getSongs()
    }
    
    //MARK: - Interactor delefate
    func setSongsImage(songsImages: Array<UIImage>) {
        delegate?.setSongsImage(songsImages)
    }
}
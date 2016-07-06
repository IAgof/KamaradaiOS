//
//  MusicListPresenter.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class MusicListPresenter: NSObject,MusicListPresenterInterface {
    //MARK: - VIPER
    var wireframe: MusicListWireframe?
    var controller: MusicViewInterface?
    var interactor: MusicListInteractorInterface?
    
    func pushBack(){
        wireframe?.goPrevController()
    }

}
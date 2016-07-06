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
    
    //MARK: - Variables
    let NO_SONG_PLAYING = -1
    var lastSongSelectedIndex = -1

    //MARK: - Interface
    func pushBack(){
        wireframe?.goPrevController()
    }

    func viewDidLoad() {
        controller?.initVariables()
        
        interactor?.getSongs()
    }

    func togglePlayOrPause(index:Int){

        if index == lastSongSelectedIndex { // Pause mode
            lastSongSelectedIndex = NO_SONG_PLAYING
            
            delegate?.setStateToPlayButton(index, state: false)
            self.pauseSong()
        }else{              // Play mode
            lastSongSelectedIndex = index
            
            delegate?.setStateToPlayButton(index, state: true)
            self.playSongAtIndex(index)
        }
    }
    
    func viewWillDisappear() {
        interactor?.pauseSong()
    }
    
    func playSongAtIndex(index: Int) {
        interactor?.playSongAtIndex(index)
    }
    
    func pauseSong(){
        interactor?.pauseSong()
    }
    
    //MARK: - Interactor delefate
    func setSongsImage(songsImages: Array<UIImage>) {
        delegate?.setSongsImage(songsImages)
    }
}
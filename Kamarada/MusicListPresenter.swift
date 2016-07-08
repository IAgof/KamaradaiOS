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
    let NO_SONG_SELECTED = -1
    var lastSongSelected = -1
    var lastSongPlayed = -1
    
    //MARK: - Interface
    func pushBack(){
        wireframe?.goPrevController()
        
        lastSongPlayed = NO_SONG_PLAYING
        lastSongSelected = NO_SONG_SELECTED
    }
    
    func viewDidLoad() {
        controller?.initVariables()
        
        interactor?.getSongs()
        
        lastSongSelected =  (interactor?.getSongSaved())!
        
        if lastSongSelected != NO_SONG_SELECTED {
            delegate?.setselectedCellIndexPath(NSIndexPath(forRow: lastSongSelected, inSection: 0))
        }
    }

    func togglePlayOrPause(index:Int){
        if index == lastSongPlayed { // Pause mode
            lastSongPlayed = NO_SONG_PLAYING
            
            delegate?.setStateToPlayButton(index, state: false)
            self.pauseSong()
        }else{              // Play mode
            
            if lastSongSelected != index {
                musicSelectedCell(index)
            }
            
            lastSongPlayed = index
            
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
    
    func validateSongEvent(){
        interactor?.saveSongToPreferences(lastSongSelected)
        self.pushBack()
    }
    
    func musicSelectedCell(index: Int) {
       
        if lastSongSelected == index {
            
            self.deselectCell(index)
        }else{
            
            self.deselectCell(lastSongSelected)
            
            delegate?.selectCell(index)
            lastSongSelected = index
        }
        interactor?.pauseSong()
    }
    
    //MARK: - Inner functions
    func deselectCell(index:Int){

        if index != NO_SONG_SELECTED {
            delegate?.deselectCell(index)
            delegate?.setStateToPlayButton(index, state: false)
        }

        interactor?.pauseSong()
        
        lastSongSelected = NO_SONG_SELECTED
        lastSongPlayed = NO_SONG_SELECTED
    }
    
    //MARK: - Interactor delefate
    func setSongsImage(songsImages: Array<UIImage>) {
        delegate?.setSongsImage(songsImages)
    }
}
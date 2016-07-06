//
//  MusicListInteractor.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import AVFoundation

class MusicListInteractor: NSObject,MusicListInteractorInterface {
    //MARK: - VIPER
    var presenter:MusicListPresenterInterface?
    var delegate:MusicInteractorDelegate?
    
    //MARK: - Variables
    var songs:Array<Song>!

    //    var playingSong
    
    
    //MARK: - Interface
    func getSongs() {
        songs = SongProvider().getSongs()
        
        self.retrieveSongsImageToView(songs)
    }
    
    func playSongAtIndex(index: Int) {
        
    }
    
    func pauseSong() {
        
    }
    
    
    //MARK: - Inner functions
    func retrieveSongsImageToView(songs:Array<Song>) {
        var songsImages = Array<UIImage>()
        
        for song in songs {
            songsImages.append(song.coverImage)
        }

        delegate?.setSongsImage(songsImages)
    }
    
    func getSongAsset(song:Song) -> AVAsset {
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(song.getSongName(), ofType: "mp3")!)
        return  AVAsset.init(URL: audioURL)
    }
}
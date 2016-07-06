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
    var audioPlayer = AVAudioPlayer()

    //    var playingSong
    
    
    //MARK: - Interface
    func getSongs() {
        songs = SongProvider().getSongs()
        
        self.retrieveSongsImageToView(songs)
    }
    
    func playSongAtIndex(index: Int) {
        let url = getSongAsset(songs[index])
        
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer = sound
            sound.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func pauseSong() {
        audioPlayer.pause()
    }
    
    
    //MARK: - Inner functions
    func retrieveSongsImageToView(songs:Array<Song>) {
        var songsImages = Array<UIImage>()
        
        for song in songs {
            songsImages.append(song.coverImage)
        }

        delegate?.setSongsImage(songsImages)
    }
    
    func getSongAsset(song:Song) -> NSURL {
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(song.getSongName(), ofType: "mp3")!)
        return  audioURL
    }
}
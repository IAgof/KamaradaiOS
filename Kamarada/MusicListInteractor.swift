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
    var isPlaying = false
    
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
        
        isPlaying = true
    }
    
    func pauseSong() {
        if isPlaying {
            audioPlayer.pause()
        }
        isPlaying = false
    }
    
    func saveSongToPreferences(index:Int) {
        var song = ""

        if index == -1 {
            song = self.getDefaultSongName()
        }else{
            song = songs[index].getSongName()
        }
        
        Utils().saveToPreferences(song, key: ConfigPreferences().SONG_SAVED)
    }
    
    func getDefaultSongName() -> String {
        return ConfigPreferences().KAMARADA_DEFAULT_SONG
    }
    
    func getSongSaved() -> Int{
        let song = Utils().getValueFromPreferences(ConfigPreferences().SONG_SAVED)
        
        var songPosition = -1
        for i in 0...(songs.count - 1) {
            if song == songs[i].getSongName(){
                songPosition = i
            }
        }
        return songPosition
    }
    
    //MARK: - Inner functions
    func retrieveSongsImageToView(songs:Array<Song>) {
        var songsImages = Array<UIImage>()
        var songsTransitionImage = Array<UIImage>()
        
        for song in songs {
            songsImages.append(song.coverImage)
            songsTransitionImage.append(song.transitionImage)
        }

        delegate?.setSongsImage(songsImages)
        delegate?.setSongsTransitionImage(songsTransitionImage)
    }
    
    func getSongAsset(song:Song) -> NSURL {
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(song.getSongName(), ofType: "mp3")!)
        return  audioURL
    }
}
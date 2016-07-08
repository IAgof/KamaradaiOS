//
//  SongProvider.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 6/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class SongProvider: NSObject {
    
    func getSongs() -> Array<Song> {
        var songsArray = Array<Song>()
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_breaktime")!,
            transitionImage: UIImage(named: "music_list_vinyl")!,
            songName: "Breaktime"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_evilplan")!,
            transitionImage: UIImage(named: "music_list_vinyl")!,
            songName: "EvilPlanFX"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_lively")!,
            transitionImage: UIImage(named: "music_list_vinyl")!,
            songName: "LivelyLumpsucker"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_wagon")!,
            transitionImage: UIImage(named: "music_list_vinyl")!,
            songName: "WagonWheel"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_camera_motor")!,
            transitionImage: UIImage(named: "music_list_film_roll")!,
            songName: "kamarada_audio"))
        
        return songsArray
    }
}
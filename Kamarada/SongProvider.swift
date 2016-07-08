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
            songName: "Breaktime"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_evilplan")!,
            songName: "EvilPlanFX"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_lively")!,
            songName: "LivelyLumpsucker"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_wagon")!,
            songName: "WagonWheel"))
        
        songsArray.append(Song(coverImage: UIImage(named: "music_list_quit_music")!,
            songName: "kamarada_audio"))
        
        return songsArray
    }
}
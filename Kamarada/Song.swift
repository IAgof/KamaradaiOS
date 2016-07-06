//
//  Song.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class Song: NSObject {
    
    var coverImage:UIImage!
    var songName:String!
    
    init(coverImage:UIImage,songName:String) {
        self.coverImage = coverImage
        self.songName = songName
    }
    
    func getCoverImage() -> UIImage {
        return coverImage
    }
    
    func getSongName() -> String {
        return songName
    }
}
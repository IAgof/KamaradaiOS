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
    var transitionImage:UIImage!
    var songName:String!
    
    init(coverImage:UIImage,
         transitionImage:UIImage,
         songName:String) {
        
        self.coverImage = coverImage
        self.transitionImage = transitionImage
        self.songName = songName
    }
    
    func getCoverImage() -> UIImage {
        return coverImage
    }
    
    func getSongName() -> String {
        return songName
    }
}
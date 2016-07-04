//
//  PlayerItem.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 17/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class PlayerItem:NSObject{
    
    var movieURL:NSURL
    
    init(movieURL:NSURL) {
        self.movieURL = movieURL
    }
    
    func setVideoURL(movieURL:NSURL){
        self.movieURL = movieURL
    }
    
    func getMovieURL()->NSURL{
        return movieURL
    }
}
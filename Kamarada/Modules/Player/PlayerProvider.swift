//
//  PlayerProvider.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 17/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class PlayerProvider:NSObject{
    
    func getMovieList()->Array<NSURL>{
        var movieList = Array<NSURL>()
        
        let path = NSBundle.mainBundle().pathForResource("video", ofType:"m4v")
        
        movieList.append(NSURL(fileURLWithPath: path!))
        
        return movieList
    }
    
    
    func getTestVideo()->NSURL{
      let path = NSBundle.mainBundle().pathForResource("video", ofType:"mp4")
        
        if let pathAux = path{
            return NSURL(fileURLWithPath: pathAux)

        }else{
            return NSURL()
        }
    }
}
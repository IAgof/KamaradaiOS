//
//  PlayerInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 17/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class PlayerInteractor: NSObject,PlayerInteractorInterface {
    
    func findVideosToPlay()->(NSURL){
        return PlayerProvider().getTestVideo()
    }
}

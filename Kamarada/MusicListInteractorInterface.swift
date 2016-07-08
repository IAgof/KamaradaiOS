//
//  MusicListInteractorInterface.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol MusicListInteractorInterface {
    
    func getSongs()
    func getSongSaved() -> Int
    func playSongAtIndex(index:Int)
    func pauseSong()
    func saveSongToPreferences(index:Int) 
}

protocol MusicInteractorDelegate {
    func setSongsImage(songsImages:Array<UIImage>)
    func setSongsTransitionImage(songsImages:Array<UIImage>)
}
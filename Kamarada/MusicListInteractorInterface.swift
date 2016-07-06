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
    func playSongAtIndex(index:Int)
    func pauseSong()
}

protocol MusicInteractorDelegate {
    func setSongsImage(songsImages:Array<UIImage>)
}
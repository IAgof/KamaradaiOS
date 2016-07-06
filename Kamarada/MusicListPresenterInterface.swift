//
//  MusicListPresenterInterface.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

protocol MusicListPresenterInterface {
    func pushBack()
    func viewDidLoad()
    func viewWillDisappear()
    func playSongAtIndex(index:Int)
    func pauseSong()
    func togglePlayOrPause(index:Int)
}

protocol MusicPresenterDelegate {
    func setSongsImage(songsImages: Array<UIImage>)
    func setStateToPlayButton(index:Int, state:Bool)
}
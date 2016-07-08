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
    func musicSelectedCell(index:Int)
    func validateSongEvent()
}

protocol MusicPresenterDelegate {
    func setSongsImage(songsImages: Array<UIImage>)
    func setStateToPlayButton(index:Int, state:Bool)
    func selectCell(index:Int)
    func deselectCell(index:Int)
    func setselectedCellIndexPath(index:NSIndexPath)
}
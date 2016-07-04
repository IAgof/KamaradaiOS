//
//  PlayerPresenterInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

protocol PlayerPresenterInterface {
    
    func createVideoPlayer(videoPath:String)
    func layoutSubViews()
    func onVideoStops()
    func videoPlayerViewTapped()
    func pushPlayButton()
    func updateSeekBar()
}


protocol PlayerDelegate {
    func PlayerDidCancelAddAction()
}
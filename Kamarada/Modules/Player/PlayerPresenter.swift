//
//  PlayerPresenter.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

class PlayerPresenter:NSObject,PlayerPresenterInterface{
    
    //MARK: - VIPER
    var playerInteractor: PlayerInteractorInterface?
    var controller: PlayerInterface?
    var playerDelegate: PlayerDelegate?
    
    var wireframe: PlayerWireframe?
    var recordWireframe: RecordWireframe?


    //MARK: - Variables
    var isPlaying = false
    
    //MARK: - Init
    func createVideoPlayer(videoPath:String) {
        controller?.setPlayerMovieURL(NSURL.init(fileURLWithPath: videoPath))
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.controller?.createVideoPlayer()
            })
        }
    }
    
    func layoutSubViews(){
        if let view = self.controller?.getView(){
            self.controller?.updateLayers()
        }
    }
    //MARK: - Handler
    func onVideoStops() {
        isPlaying = false
        
        controller?.setUpVideoFinished()
    }
    
    func pushPlayButton() {
        if isPlaying == false {
            self.playPlayer()
        }
    }
    
    func videoPlayerViewTapped() {
        if(isPlaying){
            controller?.pauseVideoPlayer()
            isPlaying = false
        }else{
            playPlayer()
        }
    }
    
    func playPlayer() {
        controller?.playVideoPlayer()
        isPlaying = true
    }
    func updateSeekBar() {
        controller!.updateSeekBarOnUI()
    }
}
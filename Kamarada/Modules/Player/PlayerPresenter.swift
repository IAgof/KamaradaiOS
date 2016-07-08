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

    //Timer
    var progressTime = 0.0
    var progressTimer:NSTimer!
    var videoDuration = 0.0
    let progressSteps = 400.0
    
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
        
        self.stopTimer()
    }
    
    func resetVideoPlayer() {
        if isPlaying {
            isPlaying = false
            controller?.pauseVideoPlayer()
            self.stopTimer()
        }
    }

    func pushPlayButton() {
        if isPlaying == false {
            self.playPlayer()
        }
    }
    
    func videoPlayerViewTapped() {
        if(isPlaying){
            controller?.pauseVideoPlayer()
            self.pauseTimer()
            
            isPlaying = false
        }else{
            playPlayer()
        }
    }
    
    func playPlayer() {
        controller?.playVideoPlayer()
        
        self.startTimer()
        
        isPlaying = true
    }
    
    func updateSeekBar() {
        controller!.updateSeekBarOnUI()
    }
    
    func setVideoPlayerDuration(duration:Double) {
        self.videoDuration = duration
    }
    
    //MARK: - Progress Bar
    @objc func updateProgressBar(){
        
        let delay = videoDuration/(progressSteps*Double(videoDuration))
        
        progressTime  += delay
        
        if((progressTime <= 1.0)){
            playerDelegate?.setProgressToSeekBar(Float(progressTime))
            //            Utils().debugLog("progress time = \(progressTime)")
        }else{
            self.stopTimer()
            Utils().debugLog("Reset progress time")
        }
    }
    
    func startTimer(){
        let videoStepDuration = videoDuration / progressSteps

        //Start timer
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(videoStepDuration,
                                                               target: self,
                                                               selector: #selector(self.updateProgressBar),
                                                               userInfo: nil,
                                                               repeats: true)
    }
    
    func pauseTimer() {
        progressTimer.invalidate()
    }
    
    func stopTimer()  {
        progressTimer.invalidate()
        
        progressTime = 0.0
        playerDelegate?.setProgressToSeekBar(Float(progressTime))
    }
}
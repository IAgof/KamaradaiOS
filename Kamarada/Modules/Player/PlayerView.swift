//
//  PlayerView.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerView: UIView,PlayerInterface {
    //MARK: - VIPER
    var eventHandler: PlayerPresenterInterface?
    
    //MARK: - Variables
    var movieURL:NSURL!
    var player:AVPlayer?
    var playerLayer: AVPlayerLayer?

    //MARK: - Outlets
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var seekSlider: UISlider!
    
    var playerRateBeforeSeek: Float = 0

    class func instanceFromNib() -> UIView {
        let view = UINib(nibName: "PlayerView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
        return view
    }
    
    override func awakeFromNib() {
        
    }
    
    func setPlayerMovieURL(movieURL: NSURL) {
        self.movieURL = movieURL
    }
    
    override func layoutSubviews() {
        self.eventHandler?.layoutSubViews()
    }
    
    func updateLayers(){
        self.superview?.layoutIfNeeded()
        let superViewFrame = (self.superview?.frame)!
        self.frame = CGRectMake(0, 0, superViewFrame.width, superViewFrame.height)

        if (playerLayer != nil){
            playerLayer!.frame = self.frame
            self.playerContainer.frame = self.frame
        }
    }
    
    func getView() -> UIView {
        return self
    }
    
    //MARK: - Player Interface
    func createVideoPlayer(){
        self.setViewPlayerTappable()
        self.initSeekEvents()
        
        //Test share interface
//        movieURL =  NSURL.init(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType:"m4v")!)
        
        let avAsset: AVURLAsset = AVURLAsset(URL: movieURL!, options: nil)
        let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerView.onVideoStops),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)

        player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1000), queue: dispatch_get_main_queue()) { _ in
            if self.player!.currentItem?.status == .ReadyToPlay {
                self.eventHandler?.updateSeekBar()
            }
        }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.frame
        player?.currentItem?.seekToTime(CMTime.init(value: 3, timescale: 10))

        self.playerContainer.layoutIfNeeded()
        self.playerContainer.layer.addSublayer(playerLayer!)
        
        self.playerContainer.bringSubviewToFront(seekSlider)
    }
    
    func updateSeekBarOnUI(){
        let duration = player?.currentItem?.duration.seconds
        let currentTime = player?.currentTime().seconds
        
        seekSlider.setValue(Float((currentTime!/duration!)), animated: true)
    }
    
    func setViewPlayerTappable(){
        let singleFingerTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(PlayerView.videoPlayerViewTapped))
        playerContainer.addGestureRecognizer(singleFingerTap)
    }
    
    func initSeekEvents(){
        seekSlider.addTarget(self, action: #selector(PlayerView.sliderBeganTracking),
                             forControlEvents: UIControlEvents.TouchDown)
        seekSlider.addTarget(self, action: #selector(PlayerView.sliderEndedTracking),
                             forControlEvents: UIControlEvents.TouchUpInside)        
        seekSlider.addTarget(self, action: #selector(PlayerView.sliderValueChanged),
                             forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func videoPlayerViewTapped(){
        eventHandler?.videoPlayerViewTapped()
    }
    @IBAction func pushPlayButton(sender: AnyObject) {
        eventHandler?.pushPlayButton()
    }
    
    func sliderBeganTracking(){
        playerRateBeforeSeek = player!.rate
        player!.pause()
    }
    
    func sliderEndedTracking(){
        let videoDuration = CMTimeGetSeconds(player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        
        player!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.player!.play()
            }
        }
    }
    func sliderValueChanged(){

    }
    
    func setUpVideoFinished(){
        player?.currentItem?.seekToTime(CMTime.init(value: 1, timescale: 10))
        playOrPauseButton.hidden = false
    }
    
    func onVideoStops(){
        eventHandler?.onVideoStops()
    }
    
    func pauseVideoPlayer(){
        player!.pause()
        
        playOrPauseButton.hidden = false
        
        Utils().debugLog("Video has stopped")
    }
    
    func playVideoPlayer(){
        player!.play()
        
        playOrPauseButton.hidden = true
        
        //Start timer

        Utils().debugLog("Playing video")
    }
}
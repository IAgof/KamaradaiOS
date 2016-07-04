//
//  CameraRecorderInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 30/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage
import AVFoundation

class CameraRecorderInteractor{

    var filterToWriter :GPUImageFilter?
    var movieWriter: GPUImageMovieWriter?
    var clipsArray:[String] = []
    var videoCamera: GPUImageVideoCamera?
    var resolutionSize:Resolution?
    
    let videoExtension = "kamaradaClip.m4v"
    var resolution: String?{
        didSet {
            resolutionSize = Resolution.init(AVResolution: resolution!)
        }
    }
    
    func recordVideo(completion:(String)->Void){
        
        let clipPath = getNewClipPath()
        self.clipsArray.append(clipPath)

        let clipURL = NSURL.init(fileURLWithPath: clipPath)
        
        Utils().debugLog("PathToMovie: \(clipPath)")
        self.movieWriter = GPUImageMovieWriter.init(movieURL: clipURL, size: CGSizeMake((resolutionSize?.width)!,(resolutionSize?.height)!))
        self.movieWriter!.encodingLiveVideo = true
        self.videoCamera?.audioEncodingTarget = movieWriter
        
        self.movieWriter!.startRecording()
        
        Utils().debugLog("Recording movie starts")
        filterToWriter?.addTarget(movieWriter)
        
        completion("Record Starts")
    }
    
    func stopRecordVideo(completion:(Double)->Void){ //Stop Recording
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            Utils().debugLog("Starting to stop record video")
            
            self.filterToWriter!.removeAllTargets()
            
//            self.videoCamera.audioEncodingTarget = nil
            
            self.movieWriter!.finishRecordingWithCompletionHandler{ () -> Void in
                let clipURL = NSURL.init(fileURLWithPath: self.clipsArray[(self.clipsArray.count - 1) ])

                Utils().debugLog("Stop recording video")
                ClipsAlbum.sharedInstance.saveVideo(clipURL)
                self.movieWriter!.endProcessing()
                self.movieWriter = nil
                
                completion(self.getVideoLenght(clipURL))
            }
        }
    }
    
    func getVideoLenght(url:NSURL) -> Double {
        let asset = AVAsset.init(URL: url)
        return asset.duration.seconds
    }
    func setInput(input: GPUImageInput){
        self.filterToWriter = input as? GPUImageFilter
        if movieWriter != nil{
            filterToWriter?.addTarget(movieWriter)
        }
    }
    
    func setVideoCamera(videoCamera: GPUImageVideoCamera){
        self.videoCamera = videoCamera
    }
    
    func setResolution(resolution:String){
        self.resolution = resolution
    }
    
    func getNewClipPath()->String{
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        path =  path + "/\(Utils().giveMeTimeNow())" + videoExtension
        
        return path
    }
    
    func getClipsArray() -> [String] {
        return clipsArray
    }
    func resetClipsArray(){
        clipsArray = []
    }
}
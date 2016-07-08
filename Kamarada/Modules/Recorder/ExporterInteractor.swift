//
//  ExporterInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 30/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import AVFoundation

class ExporterInteractor:NSObject{
    var videosArray: [String] = []
    var clipDuration = 0.0
    var exportedPresetQuality:String!

    init(videosArray:[String]) {
        super.init()
        self.videosArray = videosArray
        exportedPresetQuality = initQuality()
    }

    func initQuality()->String{

        return AVAssetExportPresetHighestQuality
    }

    //Merge videos in VideosArray and export to Documents folder and PhotoLibrary
    func getNewPathToExport()->String{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let exportPath = (documentDirectory as NSString).stringByAppendingPathComponent("mergeVideona-\(Utils().giveMeTimeNow()).m4v")
        
        return exportPath
    }
    
    func exportVideos(completionHandler:(String,Double)->Void) {
        let exportPath = self.getNewPathToExport()
        
        var videoTotalTime:CMTime = kCMTimeZero
        
        let audioName = Utils().getValueFromPreferences(ConfigPreferences().SONG_SAVED)
        
        // - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo,
                                                                     preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        // 2 - Get Audio asset
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(audioName, ofType: "mp3")!)
        let audioAsset = AVAsset.init(URL: audioURL)
        
        // - Add assets to the composition
        for path in videosArray{
            // 2 - Get Video asset
            let videoURL: NSURL = NSURL.init(fileURLWithPath: path)
            let videoAsset = AVAsset.init(URL: videoURL)
            
            
            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                               ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] ,
                                               atTime: videoTotalTime)
                
                Utils().debugLog("el tiempo total del video es: \(videoTotalTime.seconds)")
                videoTotalTime = CMTimeAdd(videoTotalTime, videoAsset.duration)
            } catch _ {
//                Utils().debugLog("Error trying to create videoTrack")
                completionHandler("Error trying to create videoTrack",0.0)
            }
        }
        // 3.2 - Audio track
        let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTotalTime),
                                           ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0] ,
                                           atTime: kCMTimeZero)
        } catch _ {
            Utils().debugLog("Error trying to create audioTrack")
        }
        
        // 4 - Get path

        let url = NSURL(fileURLWithPath: exportPath)
        
        // 5 - Create Exporter
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: exportedPresetQuality)
        exporter!.outputURL = url
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter!.exportAsynchronouslyWithCompletionHandler() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.clipDuration = videoTotalTime.seconds
                Utils().debugLog("la duracion del clip es \(self.clipDuration)")
                completionHandler(exportPath,videoTotalTime.seconds)

                ExportedAlbum.sharedInstance.saveVideo(NSURL.init(fileURLWithPath: exportPath))
            })
        }
    }
}
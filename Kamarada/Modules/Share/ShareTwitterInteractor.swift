//
//  ShareTwitterInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 6/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import Accounts
import Social
import AVFoundation

class ShareTwitterInteractor: ShareSocialNetworkInteractor {
    
    func share() {
        let videoURL = self.getShareMovieURL()
        
        if canUploadVideoToTwitter(videoURL) {
            let videoData = self.getVideoData(videoURL)
            var status = TwitterVideoUpload.instance().setVideoData(videoData)
            TwitterVideoUpload.instance().statusContent = Utils().getStringByKeyFromShare(ShareConstants().VIDEONATIME_HASTAGH)
            
            if status == false {
                self.createAlert(Utils().getStringByKeyFromShare(ShareConstants().TWITTER_MAX_SIZE))
                return
            }
            
            status = TwitterVideoUpload.instance().upload({
                errorString in
                var messageToPrintOnView = ""
                
                if (errorString != nil){
                    let codeAndMessage = self.convertStringToCodeAndMessage(errorString)
                    messageToPrintOnView = "Error with code: \(codeAndMessage.0) \n description: \(codeAndMessage.1) "
                }else{
                    messageToPrintOnView = Utils().getStringByKeyFromShare(ShareConstants().UPLOAD_SUCCESFULL)
                }
                
                self.createAlert(messageToPrintOnView)
            })
        }else{
           self.createAlert(Utils().getStringByKeyFromShare(ShareConstants().TWITTER_MAX_LENGHT))
        }
    }

    func createAlert(message:String){
        Utils().debugLog(message)
        self.setAlertCompletionMessageOnTopView(message)
    }
    
    func canUploadVideoToTwitter(movieURL:NSURL)->Bool{
        let asset = AVAsset.init(URL: movieURL)
        let duration = asset.duration.seconds
        
        if (duration <= 30){
            return true
        }else{
            return false
        }
    }
    
    func getVideoData(url:NSURL) -> NSData {
        if let path:String = url.path{
            if let data = NSFileManager.defaultManager().contentsAtPath(path){
                return data
            }else{
                return NSData()
            }
        }else{
            return NSData()
        }
    }
    
    func convertStringToCodeAndMessage(jsonStr:String) -> (String,String){
        let data = jsonStr.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
        var code:Int = 0
        var message:String = ""
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            if let dict = json as? [String: AnyObject] {
                if let errors = dict["errors"] as? [AnyObject] {
                    for dict2 in errors {
                        code = (dict2["code"] as? Int)!
                        message = (dict2["message"] as? String)!
                        print(code)
                        print(message)
                    }
                }
            }
            return ("\(code)" ,message)
        }
        catch {
            print(error)
            return ("","")
        }
    }
}
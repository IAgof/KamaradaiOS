//
//  ShareYoutubeInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 6/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import Alamofire

class ShareYoutubeInteractor: ShareSocialNetworkInteractor{
    var viewControllerOnTop:UIViewController?
    
    override init(moviePath: String, socialName: String) {
        super.init(moviePath: moviePath, socialName: socialName)
        
        viewControllerOnTop = getViewControllerOnTop()
    }
    
    
    func share(){        
        let youtubeScope = "https://www.googleapis.com/auth/youtube.upload"
        let youtubeScope2 = "https://www.googleapis.com/auth/youtube"
        let youtubeScope3 = "https://www.googleapis.com/auth/youtubepartner"
        
        GIDSignIn.sharedInstance().scopes.append(youtubeScope)
        GIDSignIn.sharedInstance().scopes.append(youtubeScope2)
        GIDSignIn.sharedInstance().scopes.append(youtubeScope3)
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
    //MARK: - Youtube upload
    func postVideoToYouTube( token:String, callback: Bool -> Void){
        
        let headers = ["Authorization": "Bearer \(token)"]
        
        let title = "Videona-\(Utils().giveMeTimeNow())"
        let description = Utils().getStringByKeyFromShare(ShareConstants().YOUTUBE_DESCRIPTION)
        
        let videoData = NSData.init(contentsOfFile: moviePath)
        Alamofire.upload(
            .POST,
            "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet",
            headers: headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data:"{'snippet':{'title' : '\(title)', 'description': '\(description)'}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"snippet", mimeType: "application/json")
                
                multipartFormData.appendBodyPart(data: videoData!, name: "video", fileName: "video.mp4", mimeType: "application/octet-stream")
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        callback(true)
                        
                        let message = Utils().getStringByKeyFromShare(ShareConstants().UPLOAD_SUCCESFULL)
                        self.setAlertCompletionMessageOnTopView(message)
                    }
                case .Failure(_):
                    callback(false)
                    let message = Utils().getStringByKeyFromShare(ShareConstants().UPLOAD_FAIL)
                    self.setAlertCompletionMessageOnTopView(message)
                }
        })
    }
}
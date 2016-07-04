//
//  ShareFacebookInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 6/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import AVFoundation

class ShareFacebookInteractor: ShareSocialNetworkInteractor,FBSDKLoginButtonDelegate,FBSDKSharingDelegate {
    
    // Facebook Delegate Methods
    
    func share(){
        
        let url = getLastAssetURL()
        
        let video: FBSDKShareVideo = FBSDKShareVideo()
        
        video.videoURL = url
        
        let content:FBSDKShareVideoContent = FBSDKShareVideoContent()
        content.video = video
        content.hashtag = FBSDKHashtag.init(string: Utils().getStringByKeyFromShare(ShareConstants().VIDEONATIME_HASTAGH))
        
        let dialog = FBSDKShareDialog.init()
        if UIApplication.sharedApplication().canOpenURL(NSURL.init(string:"fbauth2:/")!){
            dialog.mode = .Native
        }else{
            self.setAlertCompletionMessageOnTopView(Utils().getStringByKeyFromSettings(ShareConstants().NO_FACEBOOK_INSTALLED))
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.show()
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")

    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("sharerDidCancel\(error)")

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("didCompleteWithResults")

    }
}
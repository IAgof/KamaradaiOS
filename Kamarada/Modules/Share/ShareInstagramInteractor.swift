//
//  ShareInstagramInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 6/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import Photos

class ShareInstagramInteractor:ShareSocialNetworkInteractor{
   
    func share(){
        //Share to instagram
        let instagramURL = NSURL.init(string: "instagram://library?LocalIdentifier=\(self.getLastAssetString())")!
        if UIApplication.sharedApplication().canOpenURL(instagramURL) {
            UIApplication.sharedApplication().openURL(instagramURL)
        }else{
            self.setAlertCompletionMessageOnTopView(Utils().getStringByKeyFromSettings(ShareConstants().NO_ISTAGRAM_INSTALLED))
        }
    }
}
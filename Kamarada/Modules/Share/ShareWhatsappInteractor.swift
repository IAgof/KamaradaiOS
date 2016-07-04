//
//  ShareWhatsappInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 6/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import Social

class ShareWhatsappInteractor: ShareSocialNetworkInteractor {

    var documentationInteractionController:UIDocumentInteractionController!

    func share(){
        
        //NSURL(string: urlString!) {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "whatsapp://app")!) {
            
            let movie:NSURL = NSURL.fileURLWithPath(moviePath)
            
            documentationInteractionController = UIDocumentInteractionController.init(URL: movie)
            
            documentationInteractionController.UTI = "net.whatsapp.movie"
            
            documentationInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.getViewOnTop(), animated: true)
        }else{
            self.setAlertCompletionMessageOnTopView(Utils().getStringByKeyFromSettings(ShareConstants().NO_WHATSAPP_INSTALLED))
        }
    }
}
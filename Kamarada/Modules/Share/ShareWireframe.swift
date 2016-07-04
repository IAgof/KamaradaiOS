//
//  ShareWireframe.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let shareViewControllerIdentifier = "ShareViewController"

class ShareWireframe : NSObject {
    
    var rootWireframe : RootWireframe?
    var shareViewController : ShareViewController?
    var sharePresenter : SharePresenter?
    var playerWireframe: PlayerWireframe?
    var settingsWireframe: SettingsWireframe?
    
    var prevController:UIViewController?

    func presentShareInterfaceFromWindow(window: UIWindow) {
        let viewController = shareViewControllerFromStoryboard()
        
        rootWireframe?.showRootViewController(viewController, inWindow: window)
    }
    
    func presentShareInterfaceFromViewController(prevController:UIViewController,
                                                 videoPath:String,
                                                 numberOfClips:Int) {
        let viewController = shareViewControllerFromStoryboard()
        
        viewController.exportPath = videoPath
        viewController.numberOfClips = numberOfClips
        
        self.prevController = prevController

        prevController.showViewController(viewController, sender: nil)
    }
    
    func shareViewControllerFromStoryboard() -> ShareViewController {
        let storyboard = mainStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(shareViewControllerIdentifier) as! ShareViewController
        
        viewController.eventHandler = sharePresenter
        shareViewController = viewController
        sharePresenter?.controller = viewController
        
        return viewController
    }
    
    func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard
    }
    
    func presentPlayerInterface() {
        playerWireframe?.presentPlayerInterfaceFromViewController(shareViewController!)
    }
    
    func presentSettings(){
        settingsWireframe?.presentSettingsInterfaceFromViewController(shareViewController!)
    }
    
    func goPrevController(){
        if prevController!.isKindOfClass(RecordController) {
            (prevController as! RecordController).resetView()
        }
        
        shareViewController?.navigationController?.popToViewController(prevController!, animated: true)
    }
}
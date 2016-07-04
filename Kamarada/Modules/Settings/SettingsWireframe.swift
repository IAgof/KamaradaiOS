//
//  SettingsWireframe.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let settingsViewControllerIdentifier = "SettingsViewController"

class SettingsWireframe : NSObject {
    var rootWireframe : RootWireframe?
    var settingsViewController : SettingsViewController?
    var settingsPresenter : SettingsPresenter?
    
    var prevController:UIViewController?
    
    func presentSettingsInterfaceFromWindow(window: UIWindow) {
        let viewController = settingsViewControllerFromStoryboard()
        
        rootWireframe?.showRootViewController(viewController, inWindow: window)
    }
    
    func presentSettingsInterfaceFromViewController(prevController:UIViewController){
        let viewController = settingsViewControllerFromStoryboard()
        
        self.prevController = prevController
        
        prevController.showViewController(viewController, sender: nil)
    }
    
    func settingsViewControllerFromStoryboard() -> SettingsViewController {
        let storyboard = mainStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(settingsViewControllerIdentifier) as! SettingsViewController
        
        viewController.eventHandler = settingsPresenter
        settingsViewController = viewController
        settingsPresenter?.controller = viewController
        
        return viewController
    }
    
    func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard
    }
    
    func goPrevController(){
        settingsViewController?.navigationController?.popToViewController(prevController!, animated: true)
    }
    
    func goToAppleStoreURL(url:NSURL){
        if UIApplication.sharedApplication().canOpenURL(url){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func goToTwitterUserPage(user:String){
        let twitterURL = NSURL(string: "twitter://user?screen_name=\(user)")
        
        if UIApplication.sharedApplication().canOpenURL(twitterURL!){
            UIApplication.sharedApplication().openURL(twitterURL!)
        }else{
            let twitterBrowserURL = NSURL(string: "http://www.twitter.com/\(user)")
            UIApplication.sharedApplication().openURL(twitterBrowserURL!)
        }
    }
}
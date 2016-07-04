//
//  DetailTextWireframe.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 9/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let detailTextViewControllerIdentifier = "DetailTextController"

class DetailTextWireframe : NSObject {

    var rootWireframe : RootWireframe?
    var detailTextViewController : DetailTextController?
    var detailTextPresenter : DetailTextPresenter?
    
    var prevController:UIViewController?
    
    func presentShareInterfaceFromWindow(window: UIWindow) {
        let viewController = detailTextViewControllerFromStoryboard()
        
        rootWireframe?.showRootViewController(viewController, inWindow: window)
    }
    
    func presentShareInterfaceFromViewController(prevController:UIViewController,textRef:String) {
        let viewController = detailTextViewControllerFromStoryboard()
        
        viewController.textRef = textRef
        
        self.prevController = prevController
        
        prevController.showViewController(viewController, sender: nil)
    }
    
    func detailTextViewControllerFromStoryboard() -> DetailTextController {
        let storyboard = mainStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(detailTextViewControllerIdentifier) as! DetailTextController
        
        viewController.eventHandler = detailTextPresenter
        detailTextViewController = viewController
        detailTextPresenter?.controller = viewController
        
        return viewController
    }
    
    func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard
    }
    
    func goPrevController(){
        
        detailTextViewController?.navigationController?.popToViewController(prevController!, animated: true)
    }
}
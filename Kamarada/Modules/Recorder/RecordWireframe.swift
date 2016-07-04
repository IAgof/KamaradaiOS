//
//  RecordWireframe.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let RecordViewControllerIdentifier = "RecordViewController"

class RecordWireframe : NSObject {
    var rootWireframe : RootWireframe?
    var recordViewController : RecordController?
    var recordPresenter : RecordPresenter?
    
    func presentRecordInterfaceFromWindow(window: UIWindow) {
        let viewController = RecordViewControllerFromStoryboard()
        
        viewController.eventHandler = recordPresenter
        recordViewController = viewController
        recordPresenter?.controller = viewController
        
        rootWireframe?.showRootViewController(viewController, inWindow: window)
    }
    
    func setRecordViewControllerAsRootController() {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let homeViewController =  RecordViewControllerFromStoryboard()
        let nav = UINavigationController(rootViewController: homeViewController)
        appdelegate.window!.rootViewController = nav
    }
    
    func presentRecordInterfaceFromViewController(prevController:UIViewController) {
        let viewController = RecordViewControllerFromStoryboard()
        
        prevController.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func RecordViewControllerFromStoryboard() -> RecordController {
        let storyboard = mainStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(RecordViewControllerIdentifier) as! RecordController
        
        viewController.eventHandler = recordPresenter
        recordViewController = viewController
        recordPresenter?.controller = viewController
        
        return viewController
    }
    
    func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard
    }
    

    
    func goBackToRecordView(prevController:UIViewController){
        if prevController.isKindOfClass(ShareViewController) {
            recordViewController?.resetView()
        }
//        recordViewController?.hideFilterList()
        
        prevController.navigationController?.popToRootViewControllerAnimated(true)
    }
}
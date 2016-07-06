//
//  MusicListWireframe.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let musicListViewControllerIdentifier = "MusicListController"

class MusicListWireframe : NSObject {
    
    var rootWireframe : RootWireframe?
    var musicListViewController : MusicListController?
    var musicListPresenter : MusicListPresenter?
    
    var prevController:UIViewController?
    
    func presentMusicInterfaceFromWindow(window: UIWindow) {
        let viewController = musicListViewControllerFromStoryboard()
        
        rootWireframe?.showRootViewController(viewController, inWindow: window)
    }
    
    func presentMusicInterfaceFromViewController(prevController:UIViewController) {
        let viewController = musicListViewControllerFromStoryboard()
        
        
        self.prevController = prevController
        
        prevController.showViewController(viewController, sender: nil)
    }
    
    func musicListViewControllerFromStoryboard() -> MusicListController {
        let storyboard = mainStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(musicListViewControllerIdentifier) as! MusicListController
        
        viewController.eventHandler = musicListPresenter
        musicListViewController = viewController
        musicListPresenter?.controller = viewController
        musicListPresenter?.delegate = viewController
        
        return viewController
    }
    
    func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard
    }
    
    func goPrevController(){
        
        musicListViewController?.navigationController?.popToViewController(prevController!, animated: true)
    }
}
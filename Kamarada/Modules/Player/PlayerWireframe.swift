//
//  PlayerWireframe.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

let playerViewIdentifier = "PlayerView"

class PlayerWireframe : NSObject{//, UIViewAnimationTransition {
    
    var playerPresenter : PlayerPresenter?
    var presentedView : PlayerView?
    var rootWireframe : RootWireframe?
    
    func presentPlayerInterfaceFromViewController(viewController: UIViewController) {
        
        if  viewController is ShareViewController
        {
            let shareViewController = viewController as! ShareViewController
            let playerView = self.playerView()
            shareViewController.playerView.addSubview(playerView)
            
            playerView.eventHandler = playerPresenter
            playerPresenter?.controller = playerView
            
            presentedView = playerView
        }

    }
    
    func playerView() -> PlayerView {
        let playerView: PlayerView = PlayerView.instanceFromNib() as! PlayerView
        return playerView
    }
    
}
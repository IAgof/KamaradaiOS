//
//  HideDiscTransition.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 6/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit

class HideDiscTransition: NSObject {
    
    func animateTransition(transitionView: UIView, completion: ((Bool) -> Void)?) {
        dispatch_async(dispatch_get_main_queue()) {
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                var initFrame = transitionView.frame
                initFrame.origin.x -= 0
                
                var finishFrame = transitionView.frame
                finishFrame.origin.x -= initFrame.size.width/2
                
                transitionView.frame = initFrame
                transitionView.frame = finishFrame
                
                }, completion: { finished in
                    print("Transition presentation finished")
            })
        }
    }
}

//
//  KamaradaController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

class KamaradaController: UIViewController {
    let tracker = VideonaTracker()
    
    override func viewDidLoad() {
        print("View did load in \n \(self)")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("View will dissappear in \n \(self)")
        
        tracker.identifyMixpanel()
        
        tracker.startTimeInActivityEvent()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("View will dissappear in \n \(self)")
        
        tracker.sendTimeInActivity(getControllerName())
    }
    
    func getControllerName()->String{
        return String(object_getClass(self))
    }
    
    func getTrackerObject() -> VideonaTracker {
        return self.tracker
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
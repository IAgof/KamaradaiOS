//
//  DetailSettingsController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Mixpanel

class DetailSettingsController: UIViewController {
    
    @IBOutlet weak var detailTextView: UITextView!
    #if DEBUG
    var mixpanel = Mixpanel.init(token: AnalyticsConstants().MIXPANEL_TOKEN, andFlushInterval: 2)
    #else
    var mixpanel = Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
    #endif
    
    var detailSettings: String? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailSettings {
            if (detailTextView != nil){
                self.detailTextView.text=detail
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.startTimeInActivityEvent()

        configureView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.sendTimeInActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTimeInActivityEvent(){
        mixpanel.timeEvent(AnalyticsConstants().TIME_IN_ACTIVITY)
    }
    func sendTimeInActivity() {
        print("Sending AnalyticsConstants().TIME_IN_ACTIVITY")
        //NOT WORKING -- falta el comienzo time_event para arrancar el contador
        
        let whatClass = String(object_getClass(self))
        print("what class is \(whatClass)")
        
        let viewProperties = [AnalyticsConstants().ACTIVITY:whatClass]
        mixpanel.track(AnalyticsConstants().TIME_IN_ACTIVITY, properties: viewProperties)
        mixpanel.flush()
    }
}
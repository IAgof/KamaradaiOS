//
//  DetailSettingsController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit

class DetailSettingsController: UIViewController {
    
    @IBOutlet weak var detailTextView: UITextView!
    
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
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
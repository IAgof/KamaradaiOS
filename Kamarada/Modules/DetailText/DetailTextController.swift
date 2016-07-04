//
//  DetailTextController.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 9/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit

class DetailTextController: VideonaController,DetailTextInterface {
    var eventHandler: DetailTextPresenterInterface?
    
    @IBOutlet weak var detailTextFiled: UITextView!
    
    var textRef: String? {
        didSet {
//            eventHandler?.setTextOnView(textRef!)
        }
    }
    
    @IBAction func pushBack(sender: AnyObject) {
        eventHandler?.pushBack()
    }
    
    func setTextToTextView(text: String) {
        detailTextFiled.text = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler?.setTextOnView(textRef!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

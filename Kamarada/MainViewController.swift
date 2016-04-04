//
//  ViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 28/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage
import AssetsLibrary

class MainViewController: UIViewController {
    
    //MARK: - Background constants
    let woodBackground = "activity_record_background_wood.png"
    let leatherBackground = "activity_record_background_leather.png"
    
    let woodImageButton = "activity_record_skin_wood_icon_normal.png"
    let leatherImageButton = "activity_record_skin_leather_icon_normal.png"
    
    var backgroundChange:Bool = false
    
    //MARK: - Outlets
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var changeBackgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button actions
    @IBAction func pushFlash(sender: AnyObject) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func pushChangeBackground(sender: AnyObject) {
        if(backgroundChange==false){//Change to leatherBackground
            let image : UIImage = UIImage(named:woodBackground)!
            backgroundImage.image = image
            changeBackgroundButton.setImage(UIImage(named: leatherImageButton), forState:.Normal)
            
            backgroundChange=true
        }else{//Change to woodBackground
            let image : UIImage = UIImage(named:leatherBackground)!
            backgroundImage.image = image
            changeBackgroundButton.setImage(UIImage(named: woodImageButton), forState:.Normal)
            
            backgroundChange=false
        }
    }
}


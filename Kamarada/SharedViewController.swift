//
//  ShareViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Social

class SharedViewController: UIViewController{
    
    @IBOutlet weak var socialTableView: UITableView!
    
    @IBOutlet weak var backgroundShareView: UIView!
    
    @IBOutlet weak var whatsappImageView: UIImageView!
    @IBOutlet weak var FBImageView: UIImageView!
    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var gliphyImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get actions from ImageViews, could be buttons, but not the same shape image.
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SharedViewController.whatsappImageTapped(_:)))
        whatsappImageView.userInteractionEnabled = true
        whatsappImageView.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SharedViewController.FBImageTapped(_:)))
        FBImageView.userInteractionEnabled = true
        FBImageView.addGestureRecognizer(tapGestureRecognizer)
        
         tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SharedViewController.youtubeImageTapped(_:)))
        youtubeImageView.userInteractionEnabled = true
        youtubeImageView.addGestureRecognizer(tapGestureRecognizer)
        
         tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SharedViewController.gliphyImageTapped(_:)))
        gliphyImageView.userInteractionEnabled = true
        gliphyImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func whatsappImageTapped(img: AnyObject)
    {
        shareToWhatsApp()
    }
    func FBImageTapped(img: AnyObject)
    {
        shareToFB()
    }
    func youtubeImageTapped(img: AnyObject)
    {
        shareToYoutube()
    }
    func gliphyImageTapped(img: AnyObject)
    {
        shareToGliphy()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        let urlData = NSData(contentsOfURL: NSURL(string:"http://www.steppublishers.com/sites/default/files/stepteen2.mov")!)
        
        if ((urlData) != nil){
            
            print(urlData)
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docDirectory = paths[0]
            let filePath = "\(docDirectory)/tmpVideo.mov"
            urlData?.writeToFile(filePath, atomically: true)
            // file saved
            
            let videoLink = NSURL(fileURLWithPath: filePath)
            
            
            let objectsToShare = [textToShare,videoLink] //comment!, imageData!, myWebsite!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.setValue("Video", forKey: "subject")
            
            //New Excluded Activities Code
                activityVC.excludedActivityTypes = [ UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo, UIActivityTypePrint ]
            
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        
    }
    
    //MARK: - Share to diferent social networks
    func shareToWhatsApp(){
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            if let whatsappURL = NSURL(string: urlString) {
                
                if UIApplication.sharedApplication().canOpenURL(whatsappURL) {
                    
                    if let image = UIImage(named: "image") {
                        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                            let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).URLByAppendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.writeToURL(tempFile, options: .DataWritingAtomic)
                                let documentInteractionController = UIDocumentInteractionController(URL: tempFile)
                                documentInteractionController.UTI = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                } else {
                    // Cannot open whatsapp
                }
            }
        }
    }
    
    func shareToGliphy(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareToFB(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            self.presentViewController(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func shareToYoutube(){
        let alert = UIAlertController(title: "Alert", message: "Not yet", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

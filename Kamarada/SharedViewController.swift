//
//  ShareViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Social
import AVFoundation

class SharedViewController: UIViewController{
    
    //MARK: - Outlets
    @IBOutlet weak var socialTableView: UITableView!
    @IBOutlet weak var backgroundShareView: UIView!
    @IBOutlet weak var whatsappImageView: UIImageView!
    @IBOutlet weak var FBImageView: UIImageView!
    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var gliphyImageView: UIImageView!
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoProgressView: UIProgressView!
    
    //MARK: - Variables
//    var sharedVideoPath: String? {
//        didSet {
//            self.createVideoPlayer()
//        }
//    }
    var sharedVideoPath:String = ""
    var isPlayingVideo:Bool = false
    var player:AVPlayer?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.createVideoPlayer()
        
        self.setUpImageTaps()
        
        //Tap videoView
        let singleFingerTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(SharedViewController.videoPlayerViewTapped))
        videoPlayerView.addGestureRecognizer(singleFingerTap)
        
        //Bring playImageView to front
        videoPlayerView.bringSubviewToFront(playImageView)
        
    }
    override func viewWillDisappear(animated: Bool) {
        print("SharedViewController willDissappear")
        self.performSegueWithIdentifier("unwindToViewController", sender: self)
    }

    func setUpImageTaps(){
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //MARK: - VideoPlayer
    func createVideoPlayer(){
        print("Starts video player")
        let movieURL = NSURL.fileURLWithPath(sharedVideoPath)
        //to test:
//        let movieURL = NSURL.fileURLWithPath( NSBundle.mainBundle().pathForResource("video", ofType:"m4v")!)
        
        print("El sharedVideoPath: \(sharedVideoPath) \n La movieURL: \(movieURL)")
        
        let playerItem:AVPlayerItem = AVPlayerItem.init(URL: movieURL)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharedViewController.onVideoStops),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        
        let layer = AVPlayerLayer.init()
        layer.player = player
        layer.frame = CGRectMake(0,0, self.videoPlayerView.frame.width, self.videoPlayerView.frame.height)
        self.videoPlayerView.layer.addSublayer(layer)
    }
    
    //MARK: - OnTapp ImageVideo functions
    func videoPlayerViewTapped(){
        if isPlayingVideo {//video is playing
            player!.pause()
            
            playImageView.hidden = false
            isPlayingVideo = false
            print("Video has stopped")
        }else{//video has stopped
            player!.play()
            
            playImageView.hidden = true
            isPlayingVideo = true
            print("Playing video")
        }
      

    }
    
    func onVideoStops(){
        print("Video has finished")
        
        player?.currentItem?.seekToTime(kCMTimeZero)
        isPlayingVideo = false
        playImageView.hidden = false
    }
    //MARK: - OnTapp Image functions
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

    //MARK: - Button Actions
    @IBAction func shareButtonClicked(sender: UIButton) {
        
        let movieURL = NSURL.fileURLWithPath(sharedVideoPath)

        let objectsToShare = [movieURL] //comment!, imageData!, myWebsite!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.setValue("Video", forKey: "subject")
        
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [ UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo, UIActivityTypePrint ]
        
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    //MARK: - Share Functions
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

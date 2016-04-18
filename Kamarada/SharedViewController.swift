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
import Accounts
import Photos

class SharedViewController: UIViewController{
    
    //MARK: - Outlets
    @IBOutlet weak var socialTableView: UITableView!
    @IBOutlet weak var backgroundShareView: UIView!
    @IBOutlet weak var whatsappImageView: UIImageView!
    @IBOutlet weak var FBImageView: UIImageView!
    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var twitterImageView: UIImageView!
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoProgressView: UIProgressView!
    
    //MARK: - Variables
    
//    var sharedVideoPath:String = ""
    var isPlayingVideo:Bool = false
    var player:AVPlayer?
    var movieURL:NSURL!

    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()        // Do any additional setup after loading the view, typically from a nib.
        self.createVideoPlayer()
        
        self.setUpImageTaps()
        
        //Tap videoView
        let singleFingerTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(SharedViewController.videoPlayerViewTapped))
        videoPlayerView.addGestureRecognizer(singleFingerTap)
        
        //Bring playImageView to front
        videoPlayerView.bringSubviewToFront(playImageView)
        
//        //Set movieURL
//        movieURL = NSURL.fileURLWithPath(sharedVideoPath)
        
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
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SharedViewController.twitterImageTapped(_:)))
        twitterImageView.userInteractionEnabled = true
        twitterImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //MARK: - VideoPlayer
    func createVideoPlayer(){
        print("Starts video player")
        
        let avAsset: AVURLAsset = AVURLAsset(URL: movieURL!, options: nil)
        let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
        
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
    func twitterImageTapped(img: AnyObject)
    {
//        shareToTwitter()
        shareToInstagram()
    }

    //MARK: - Button Actions
    @IBAction func shareButtonClicked(sender: UIButton) {
        
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
                    
                    let documentationInteractionController:UIDocumentInteractionController = UIDocumentInteractionController.init(URL: movieURL)
                    
                    documentationInteractionController.UTI = "net.whatsapp.movie"
                    
                    documentationInteractionController.presentPreviewAnimated(true)
                    
                } else {
                    // Cannot open whatsapp
                    
                    let alert = UIAlertController(title: "Share", message: "No Whattsapp instaled", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)                }
            }
        }
    }

    func shareToTwitter(){
        let accountStore:ACAccountStore = ACAccountStore.init()
        let accountType:ACAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (let granted, let error) in
            let accounts = accountStore.accountsWithAccountType(accountType)
            
            if accounts.count > 0 {
                let twitterAccount = accounts[0]
                if(SocialVideoHelper.userHasAccessToTwitter()){
                    let videoData = NSData(contentsOfURL: self.movieURL)
                    SocialVideoHelper.uploadTwitterVideo(videoData, comment: "Kamarada video", account: twitterAccount as! ACAccount, withCompletion: nil)
                }else{
                    print("No access to Twitter")
                }
            }
        }

        
    }
    
    func shareToInstagram(){
        //Get last videoAsset on PhotoLibrary
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(.Video, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject as? PHAsset {
            //Share to instagram
            let instagramURL = NSURL.init(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
            if UIApplication.sharedApplication().canOpenURL(instagramURL) {
                UIApplication.sharedApplication().openURL(instagramURL)
            }
        }
        

    }
   
    func shareToFB(){
        let accountStore:ACAccountStore = ACAccountStore.init()
        let accountType:ACAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        
        let options:NSDictionary = [
            "ACFacebookAppIdKey" : "123456789",
            "ACFacebookPermissionsKey" : "publish_stream"]
//            "ACFacebookAudienceKey" : ACFacebookAudienceEveryone] // Needed only when write permissions are requested

        accountStore.requestAccessToAccountsWithType(accountType, options: options as [NSObject : AnyObject]) { (let granted, let error) in
            let accounts = accountStore.accountsWithAccountType(accountType)
            
            if accounts.count > 0 {
                let facebookAccount = accounts[0]
                if(SocialVideoHelper.userHasAccessToFacebook()){
                    let videoData = NSData(contentsOfURL: self.movieURL)
                    SocialVideoHelper.uploadFacebookVideo(videoData, comment: "Kamarada video", account: facebookAccount as! ACAccount, withCompletion: nil)
                }else{
                    print("No access to Facebook")
                }
            }
        }
        
        
    }
    func shareToYoutube(){
        let instagramURL = NSURL.init(string: "https://www.googleapis.com/youtube/v3/videos")!
        UIApplication.sharedApplication().openURL(instagramURL)
    }
    
    

}

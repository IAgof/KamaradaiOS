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
import Alamofire

class SharedViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate{
    
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
    var moviePath:String!
    var token:String!
    var isSharingYoutube:Bool = false
    
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
        
        //Google Sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    override func viewWillDisappear(animated: Bool) {
        print("SharedViewController willDissappear")
        
        if(!isSharingYoutube){//are not sharing with youtube, have to go to kamarada main view
            self.performSegueWithIdentifier("unwindToViewController", sender: self)
        }else{
            isSharingYoutube = false
        }
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
        isSharingYoutube = true
        
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
//        activityVC.excludedActivityTypes = [ UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage,  UIActivityTypePrint ]
        
        
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
    
    //    func shareToTwitter(){
    //        let accountStore:ACAccountStore = ACAccountStore.init()
    //        let accountType:ACAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    //
    //        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (let granted, let error) in
    //            let accounts = accountStore.accountsWithAccountType(accountType)
    //
    //            if accounts.count > 0 {
    //                let twitterAccount = accounts[0]
    //                if(SocialVideoHelper.userHasAccessToTwitter()){
    //                    let videoData = NSData(contentsOfURL: self.movieURL)
    //                    SocialVideoHelper.uploadTwitterVideo(videoData, comment: "Kamarada video", account: twitterAccount as! ACAccount, withCompletion: nil)
    //                }else{
    //                    print("No access to Twitter")
    //                }
    //            }
    //        }
    //
    //
    //    }
    
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
        let video: FBSDKShareVideo = FBSDKShareVideo()
        video.videoURL = movieURL
        let content:FBSDKShareVideoContent = FBSDKShareVideoContent()
        content.video = video
        let dialog = FBSDKShareDialog.init()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.show()
    }
    func shareToYoutube(){
        let youtubeScope = "https://www.googleapis.com/auth/youtube.upload"
        let youtubeScope2 = "https://www.googleapis.com/auth/youtube"
        let youtubeScope3 = "https://www.googleapis.com/auth/youtubepartner"
        
        GIDSignIn.sharedInstance().scopes.append(youtubeScope)
        GIDSignIn.sharedInstance().scopes.append(youtubeScope2)
        GIDSignIn.sharedInstance().scopes.append(youtubeScope3)
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    //MARK: - Google methods
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //        myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        
        self.presentViewController(viewController, animated: true, completion: nil)
        
        print("SignIn")
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("SignIn Dissmiss")
        
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        print("Google Sign In get user token")
        
        token = user.authentication.accessToken
        
        print("Google Sign In get user token: \(token))")
        
        self.postVideoToYouTube(){(result) -> () in
            print("result \(result)")
        }
    }

    //MARK: - Youtube upload
    func postVideoToYouTube( callback: Bool -> Void){
        
        let headers = ["Authorization": "Bearer \(token)"]
        
        let title = "Kamarada-\(self.giveMeTimeNow())"
        let description = "Video grabado con Kamarada"
        
        let videoData = NSData.init(contentsOfFile: moviePath)
        Alamofire.upload(
            .POST,
            "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet",
            headers: headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data:"{'snippet':{'title' : '\(title)', 'description': '\(description)'}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"snippet", mimeType: "application/json")

                multipartFormData.appendBodyPart(data: videoData!, name: "video", fileName: "video.mp4", mimeType: "application/octet-stream")
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        callback(true)
                        
                        self.setAlertSuccessUpload(true)
                    }
                case .Failure(_):
                    callback(false)
                    self.setAlertSuccessUpload(false)
                }
        })
    }
    
    func setAlertSuccessUpload(status: Bool){
        var message = ""
        if(status){
            message = "Success on the upload"
        }else{
            message = "Error on the upload try again"
        }
        
        let alert = UIAlertController(title: "Youtube upload", message: message, preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Functions
    
    //Make the String with date to save videos
    func giveMeTimeNow()->String{
        var dateString:String = ""
        let dateFormatter = NSDateFormatter()
        
        let date = NSDate()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "es_ES")
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 3600) //GMT +1
        dateString = dateFormatter.stringFromDate(date)
        
        print("La hora es : \(dateString)")
        
        return dateString
    }
    //MARK: - Facebook Delegate Methods

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            
            self.returnUserData()
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
}

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
import Mixpanel


class SharedViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate{
    
    //MARK: - Outlets
    @IBOutlet weak var socialTableView: UITableView!
    @IBOutlet weak var backgroundShareView: UIView!
    @IBOutlet weak var whatsappImageView: UIImageView!
    @IBOutlet weak var FBImageView: UIImageView!
    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var twitterImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    
    //Timer
    @IBOutlet weak var videoProgressView: UIProgressView!
    
    //MARK: - Variables
    
    //MIXPANEL
    let mixpanel = Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
    
    //    var sharedVideoPath:String = ""
    var isPlayingVideo:Bool = false
    var player:AVPlayer?
    var movieURL:NSURL!
    var moviePath:String!
    var movieInternalPath:String!
    var token:String!
    var isSharingYoutube:Bool = false
    var numberOfClips = 0
    var backgroundImage:UIImage!
    var documentationInteractionController:UIDocumentInteractionController!
    
    //Timer
    var progressTimer:NSTimer!
    var progressTime = 0.0
    var videoDuration = 0.0
    let progressSteps = 400.0
    
    //MARK: - Constants
    let preferences = NSUserDefaults.standardUserDefaults()
    
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
        
        videoProgressView.transform = CGAffineTransformScale(videoProgressView.transform, 1, 3)
        
        self.startTimeInActivityEvent()
        
        self.setShareBackgroundImage(backgroundImage)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        Utils().debugLog("SharedViewController will Appear")
        self.navigationController?.navigationBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        Utils().debugLog("SharedViewController willDissappear")
        
        pauseVideoPlayer()
        
        if(!isSharingYoutube){//are not sharing with youtube, have to go to kamarada main view
            //            self.performSegueWithIdentifier("unwindToViewController", sender: self)
        }else{
            isSharingYoutube = false
        }
        
        self.sendTimeInActivity()
        
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
    
    //MARK: - Change background
    func setShareBackgroundImage(image:UIImage){
        backgroundImageView.image = image
    }
    
    //MARK: - VideoPlayer
    func createVideoPlayer(){
        Utils().debugLog("Starts video player")
        
        let avAsset: AVURLAsset = AVURLAsset(URL: movieURL!, options: nil)
        let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharedViewController.onVideoStops),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        
        //Get video duration to player progressView
        videoDuration = avAsset.duration.seconds
        
        let layer = AVPlayerLayer.init()
        layer.player = player
        
        self.videoPlayerView.layoutIfNeeded()
        let offsset = CGFloat(-20)
        layer.frame = CGRectMake(0,0, (self.videoPlayerView.bounds.width + offsset) , (self.videoPlayerView.bounds.height + offsset))
        self.videoPlayerView.layer.addSublayer(layer)
    }
    
    //MARK: - OnTapp ImageVideo functions
    func videoPlayerViewTapped(){
        if isPlayingVideo {//video is playing
            self.pauseVideoPlayer()
        }else{//video has stopped
            self.playVideoPlayer()
        }
    }
    
    
    //MARK: - Progress Bar
    func updateProgressBar(){
        
        let delay = videoDuration/(progressSteps*Double(videoDuration))
        
        progressTime  += delay
        
        if((progressTime <= 1.0)){
            videoProgressView.setProgress(Float(progressTime), animated: false)
            //            Utils().debugLog("progress time = \(progressTime)")
        }else{
            progressTime = 0.0
            Utils().debugLog("Reset progress time")
        }
    }
    
    //MARK: - Video Player functions
    func pauseVideoPlayer(){
        player!.pause()
        
        playImageView.hidden = false
        isPlayingVideo = false
        
        if let progress = progressTimer{
            progress.invalidate()
        }
        
        Utils().debugLog("Video has stopped")
    }
    
    func playVideoPlayer(){
        player!.play()
        
        playImageView.hidden = true
        isPlayingVideo = true
        
        //Start timer
        
        let videoStepDuration = videoDuration / progressSteps
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(videoStepDuration, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        
        Utils().debugLog("Playing video")
    }
    
    func onVideoStops(){
        Utils().debugLog("Video has finished")
        
        player?.currentItem?.seekToTime(kCMTimeZero)
        isPlayingVideo = false
        playImageView.hidden = false
        
        videoProgressView.setProgress(0, animated: false)
        progressTimer.invalidate()
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
        self.updateNumTotalVideosShared()
        self.trackVideoShared("")
        
        let movie:NSURL = NSURL.fileURLWithPath(moviePath)
        
        documentationInteractionController = UIDocumentInteractionController.init(URL: movie)
        
        documentationInteractionController.UTI = "public.movie"
        
        documentationInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
    }
    
    //MARK: - Share Functions
    func shareToWhatsApp(){
        self.updateNumTotalVideosShared()
        trackVideoShared(AnalyticsConstants().WHATSAPP);
        
        //NSURL(string: urlString!) {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "whatsapp://app")!) {
            
            let movie:NSURL = NSURL.fileURLWithPath(moviePath)
            
            documentationInteractionController = UIDocumentInteractionController.init(URL: movie)
            
            documentationInteractionController.UTI = "net.whatsapp.movie"
            
            documentationInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
        }else{
            // create the alert
            let alert = UIAlertController(title: "Whatsapp", message: "No Whatsapp installed", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
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
    //                    Utils().debugLog("No access to Twitter")
    //                }
    //            }
    //        }
    //
    //
    //    }
    
    func shareToInstagram(){
        self.updateNumTotalVideosShared()
        trackVideoShared(AnalyticsConstants().INSTAGRAM);
        
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
        self.updateNumTotalVideosShared()
        trackVideoShared(AnalyticsConstants().FACEBOOK);
        
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
        self.updateNumTotalVideosShared()
        trackVideoShared(AnalyticsConstants().YOUTUBE);
        
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
        
        Utils().debugLog("SignIn")
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        Utils().debugLog("SignIn Dissmiss")
        
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        Utils().debugLog("Google Sign In get user token")
        
        //Error control
        if (error == nil) {
            token = user.authentication.accessToken
            
            Utils().debugLog("Google Sign In get user token: \(token))")
            
            self.postVideoToYouTube(){(result) -> () in
                Utils().debugLog("result \(result)")
            }
        } else {
            Utils().debugLog("\(error.localizedDescription)")
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
        
        Utils().debugLog("La hora es : \(dateString)")
        
        return dateString
    }
    //MARK: - Facebook Delegate Methods
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        Utils().debugLog("User Logged In")
        
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
        Utils().debugLog("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                Utils().debugLog("Error: \(error)")
            }
            else
            {
                Utils().debugLog("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                Utils().debugLog("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                Utils().debugLog("User Email is: \(userEmail)")
            }
        })
    }
    
    //MARK: - MIXPANEL
    //FOR VIPER: in Android this is in Activity.
    
    func trackVideoShared(socialNetwork:String) {
        trackVideoSharedSuperProperties()
        mixpanel.identify(Utils().udid)
        
        //JSON properties
        let socialNetworkProperties =
            [
                AnalyticsConstants().SOCIAL_NETWORK : socialNetwork,
                AnalyticsConstants().VIDEO_LENGTH: videoDuration,
                AnalyticsConstants().RESOLUTION: AnalyticsConstants().RESOLUTION,
                AnalyticsConstants().NUMBER_OF_CLIPS: numberOfClips,
                AnalyticsConstants().TOTAL_VIDEOS_SHARED: preferences.integerForKey(ConfigPreferences().TOTAL_VIDEOS_SHARED),
                AnalyticsConstants().DOUBLE_HOUR_AND_MINUTES: Utils().getDoubleHourAndMinutes(),
                ]
        mixpanel.track(AnalyticsConstants().VIDEO_SHARED, properties: socialNetworkProperties as [NSObject : AnyObject])
        
        mixpanel.people.increment(AnalyticsConstants().TOTAL_VIDEOS_SHARED,by: NSNumber.init(int: Int32(1)))
        mixpanel.people.set(AnalyticsConstants().LAST_VIDEO_SHARED,to: Utils().giveMeTimeNow())
    }
    
    func trackVideoSharedSuperProperties() {
        var numPreviousVideosShared:Int
        let properties = mixpanel.currentSuperProperties()
        
        if let prop = properties[AnalyticsConstants().TOTAL_VIDEOS_SHARED]{
            numPreviousVideosShared = prop as! Int
        }else{
            numPreviousVideosShared = 0
        }
        
        numPreviousVideosShared += 1
        
        //JSON properties
        
        let updateSuperProperties = [AnalyticsConstants().TOTAL_VIDEOS_SHARED: numPreviousVideosShared]
        
        mixpanel.registerSuperProperties(updateSuperProperties)
    }
    
    func updateNumTotalVideosShared(){
        var totalVideosShared = preferences.integerForKey(ConfigPreferences().TOTAL_VIDEOS_SHARED)
        totalVideosShared += 1
        preferences.setInteger(totalVideosShared, forKey: ConfigPreferences().TOTAL_VIDEOS_SHARED)
    }
    
    func startTimeInActivityEvent(){
        mixpanel.timeEvent(AnalyticsConstants().TIME_IN_ACTIVITY)
    }
    func sendTimeInActivity() {
        Utils().debugLog("Sending AnalyticsConstants().TIME_IN_ACTIVITY")
        //NOT WORKING -- falta el comienzo time_event para arrancar el contador
        
        let whatClass = String(object_getClass(self))
        Utils().debugLog("what class is \(whatClass)")
        
        let viewProperties = [AnalyticsConstants().ACTIVITY:whatClass]
        mixpanel.track(AnalyticsConstants().TIME_IN_ACTIVITY, properties: viewProperties)
        mixpanel.flush()
    }
    
}

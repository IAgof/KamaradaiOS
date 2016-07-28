//
//  ShareViewController.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Foundation

class ShareViewController: KamaradaController,ShareInterface ,
UINavigationBarDelegate ,
GIDSignInUIDelegate,GIDSignInDelegate{
    
    //MARK: - VIPER
    var eventHandler: SharePresenterInterface?
    
    //MARK: - Variables and Constants
    var titleBar = "Share video"
    var titleBackButtonBar = "Back"
    
    let reuseIdentifierCell = "shareCell"
    let shareNibName = "ShareCell"
    var listImages = Array<UIImage>()
    var listImagesPressed = Array<UIImage>()
    var listTitles = Array<String>()
    var token:String!
    var documentationInteractionController:UIDocumentInteractionController!

    var exportPath: String? {
        didSet {
            eventHandler?.setVideoExportedPath(exportPath!)
        }
    }
    
    var numberOfClips:Int? {
        didSet {
            eventHandler?.setNumberOfClipsToExport(numberOfClips!)
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var settingsNavBar: UINavigationItem!
    
    @IBOutlet weak var backgroundShareView: UIView!
    @IBOutlet weak var whatsappImageView: UIImageView!
    @IBOutlet weak var FBImageView: UIImageView!
    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var twitterImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var videoProgressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDid Load")

        eventHandler?.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        eventHandler?.viewWillDissappear()
    }
    
    //MARK: - View Init
    func createShareInterface(){
        self.setUpImageTaps()
        
        //Google Sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
        
    func setTitleList(titleList: Array<String>) {
        self.listTitles = titleList
    }
    
    func setImageList(imageList: Array<UIImage>) {
        self.listImages = imageList
    }
    func setImagePressedList(imageList: Array<UIImage>) {
        self.listImagesPressed = imageList
    }
    
    //MARK: - Button Actions
    @IBAction func shareButtonClicked(sender: UIButton) {
        eventHandler?.pushShareButton()
    }
    
    @IBAction func pushBackBarButton(sender: AnyObject) {
        eventHandler?.pushBack()
    }
    
    func setUpImageTaps(){
        //Get actions from ImageViews, could be buttons, but not the same shape image.
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ShareViewController.whatsappImageTapped(_:)))
        whatsappImageView.userInteractionEnabled = true
        whatsappImageView.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ShareViewController.FBImageTapped(_:)))
        FBImageView.userInteractionEnabled = true
        FBImageView.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ShareViewController.youtubeImageTapped(_:)))
        youtubeImageView.userInteractionEnabled = true
        youtubeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ShareViewController.instagramImageTapped(_:)))
        twitterImageView.userInteractionEnabled = true
        twitterImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: - OnTapp Image functions
    func whatsappImageTapped(img: AnyObject)
    {
        eventHandler?.pushShare("Whatsapp")
    }
    func FBImageTapped(img: AnyObject)
    {
        eventHandler?.pushShare("Facebook")
    }
    func youtubeImageTapped(img: AnyObject)
    {
        eventHandler?.pushShare("Youtube")
    }
    func instagramImageTapped(img: AnyObject)
    {
        eventHandler?.pushShare("Instagram")
    }
    
    @IBAction func pushSettingsButton(sender: AnyObject) {
        eventHandler?.goToSettings()
    }
    
    func shareVideoFromDefault(movieURL: NSURL) {
       let objectsToShare = [movieURL] //comment!, imageData!, myWebsite!]

        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if (activityVC.popoverPresentationController != nil) {
            activityVC.popoverPresentationController!.sourceView = self.shareButton
        }
        
        activityVC.setValue("Video", forKey: "subject")
        
        self.presentViewController(activityVC, animated: true, completion: nil)

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
        
        self.presentViewController(viewController, animated: false, completion: nil)
        
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
            
            eventHandler!.postToYoutube(token)
        } else {
            Utils().debugLog("\(error.localizedDescription)")
        }
    }
}
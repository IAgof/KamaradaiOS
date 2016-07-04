//
//  ShareViewController.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Foundation

class ShareViewController: VideonaController,ShareInterface ,
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
    @IBOutlet weak var shareTableView: UITableView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var settingsNavBar: UINavigationItem!
    @IBOutlet weak var expandPlayerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDid Load")

        eventHandler?.viewDidLoad()
    }
    
    //MARK: - View Init
    func createShareInterface(){
        let nib = UINib.init(nibName: shareNibName, bundle: nil)
        shareTableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifierCell)
                
        //Google Sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    func bringToFrontExpandPlayerButton(){
        self.playerView.bringSubviewToFront(expandPlayerButton)
    }
    func setNavBarTitle(title:String){
        settingsNavBar.title = title
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
        
    @IBAction func pushBackBarButton(sender: AnyObject) {
        eventHandler?.pushBack()
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
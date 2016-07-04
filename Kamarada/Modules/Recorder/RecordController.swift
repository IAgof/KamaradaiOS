//
//  ViewController.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import GPUImage

class RecordController: VideonaController,RecordViewInterface,UINavigationControllerDelegate {
    
    //MARK: - Variables VIPER
    var eventHandler: RecordPresenter?
    
    //MARK: - Outlets
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraRotationButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sepiaFilterButton: UIButton!
    @IBOutlet weak var blueFilterButton: UIButton!
    @IBOutlet weak var bwFilterButton: UIButton!
    @IBOutlet weak var cameraView: GPUImageView!

    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnailNumberClips: UILabel!
    
    var alertController:UIAlertController?
    var tapDisplay:UIGestureRecognizer?
    var pinchDisplay:UIPinchGestureRecognizer?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        eventHandler?.viewDidLoad(cameraView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Recorder view will appear")
        eventHandler?.viewWillAppear()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        eventHandler?.viewWillDisappear()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - View Config
    func configureView() {
        self.navigationController?.navigationBarHidden = true
        
        tapDisplay = UITapGestureRecognizer(target: self, action: #selector(RecordController.displayTapped))
        self.cameraView.addGestureRecognizer(tapDisplay!)
        
        pinchDisplay = UIPinchGestureRecognizer(target: self, action: #selector(RecordController.displayPinched))
        self.cameraView.addGestureRecognizer(pinchDisplay!)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func displayTapped(){
        eventHandler!.displayHasTapped(tapDisplay!)
    }
    func displayPinched(){
        eventHandler!.displayHasPinched(pinchDisplay!)
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    //MARK: - Button Actions
    @IBAction func pushGoToSettings(sender: AnyObject) {
        eventHandler?.pushSettings()
    }
    
    @IBAction func pushGoToShareView(sender: AnyObject) {
        eventHandler?.pushShare()
    }
    
    
    @IBAction func pushRecord(sender: AnyObject) {
        eventHandler?.pushRecord()
    }
    
    @IBAction func pushFlash(sender: AnyObject) {
        eventHandler?.pushFlash()
    }
    
    @IBAction func pushRotateCamera(sender: AnyObject) {
        eventHandler?.pushRotateCamera()
    }
    
    @IBAction func pushSepiaFilter(sender: AnyObject) {
        eventHandler?.pushSepiaFilter()
    }
    
    @IBAction func pushBlueFilter(sender: AnyObject) {
        eventHandler?.pushBlueFilter()
    }
    
    @IBAction func pushBWFilter(sender: AnyObject) {
        eventHandler?.pushBWFilter()
    }
    
    //MARK: - Protocol Interface
    func showRecordButton(){
        self.recordButton.selected = true
    }
    
    func showStopButton(){
        self.recordButton.selected = false
    }
    
    func recordButtonEnable(state: Bool) {
        self.recordButton.enabled = state
    }
    
    func showSettings(){
        settingsButton.hidden = false
    }
    
    func hideSettings(){
        settingsButton.hidden = true 
    }
    
    func showRecordedVideoThumb(imageView: UIImageView) {
        thumbnailView.hidden = false
        thumbnailView.addSubview(imageView)
        thumbnailView.bringSubviewToFront(thumbnailNumberClips)
    }
    
    func showNumberVideos(nClips:Int){
        thumbnailNumberClips.text = "\(nClips)"
        thumbnailNumberClips.adjustsFontSizeToFitWidth = true
    }
    
    func hideRecordedVideoThumb(){
        thumbnailView.hidden = true
    }
    
    func showFlashOn(on:Bool){
        flashButton.selected = on
    }
    
    func showFlashSupported(state:Bool){
        flashButton.enabled = state
    }
    
    func showFrontCameraSelected(){
        cameraRotationButton.selected = true
    }
    
    func showBackCameraSelected(){
        cameraRotationButton.selected = false
    }
    
    func enableShareButton(){
        shareButton.enabled = true
    }
    
    func disableShareButton(){
        shareButton.enabled = false
    }
    
    func selectSepiaButton(){
        sepiaFilterButton.selected = true
    }
    
    func unselectSepiaButton(){
        sepiaFilterButton.selected = false
    }
    
    func selectBlueButton(){
        blueFilterButton.selected = true
    }
    
    func unselectBlueButton(){
        blueFilterButton.selected = false
    }
    
    func selectBWButton(){
        bwFilterButton.selected = true
    }
    
    func unselectBWButton(){
        bwFilterButton.selected = false
    }
    

    
    
    func createAlertWaitToExport(){
        let title = Utils().getStringByKeyFromSettings(RecordConstants().WAIT_TITLE)
        let message = Utils().getStringByKeyFromSettings(RecordConstants().WAIT_DESCRIPTION)
        
        alertController = UIAlertController(title:title,message:message,preferredStyle: .Alert)
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        

        activityIndicator.center = CGPointMake(130.5, 75.5);
        activityIndicator.startAnimating()

        alertController?.view.addSubview(activityIndicator)
        self.presentViewController(alertController!, animated: false, completion:{})
    }
    
    func dissmissAlertWaitToExport(completion:()->Void){
        alertController?.dismissViewControllerAnimated(true, completion: {
            print("can go to next screen")
            completion()
        })
    }
    
    func resetView() {
        eventHandler?.resetRecorder()
    }
    
}

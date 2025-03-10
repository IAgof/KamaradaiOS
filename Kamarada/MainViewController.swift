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
import Photos
import QuartzCore
import Mixpanel
import Device_swift

class MainViewController: UIViewController{
    
    //MARK: - Background constants
    let woodBackground = "activity_record_background_wood.png"
    let leatherBackground = "activity_record_background_leather.png"
    
    let woodImageButton = "activity_record_skin_wood_icon_normal.png"
    let leatherImageButton = "activity_record_skin_leather_icon_normal.png"
    
    //MARK: - Outlets
    
    //Views
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var filterView: GPUImageView?
    @IBOutlet var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var progressImage: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    //Buttons
    @IBOutlet weak var changeBackgroundButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var rearFrontCameraButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    //Filter Buttons
    @IBOutlet weak var BWFilterButton: UIButton!
    @IBOutlet weak var sepiaFilterButton: UIButton!
    @IBOutlet weak var blueFilterButton: UIButton!
    
    //MARK: - Constants
    let videoDuration = 15.0
    let progressSteps = 400.0
    let resolution = AVCaptureSessionPreset640x480
    var clipDuration = 0.0
    let preferences = NSUserDefaults.standardUserDefaults()
    let graingImageTimeRefresh = 0.20
    
    //MARK: - Variables
    var blendProcessing :CGSize?
    var isRecording:Bool = false
    var isRearCamera:Bool = false
    var backgroundChange:Bool = false
    var waitingToMergeVideo:Bool = true
    
    var pathToMovie:String!
    var pathToMergeMovie:String
    var urlToMergeMovieInPhotoLibrary:NSURL!
    
    var videosArray:[String] = []

    var shareDialogController:UIViewController?
    var cornerRadiusThumbnail:CGFloat = 20.0
    
    //MIXPANEL
    var mixpanel:Mixpanel
    
    //Timer
    var progressTimer:NSTimer
    var timer:NSTimer? = nil;
    let grainFilters = ["silent_film_overlay_a.png"
        ,"silent_film_overlay_b.png"
        ,"silent_film_overlay_c.png"
        ,"silent_film_overlay_d.png"
        ,"silent_film_overlay_e.png"
        ,"silent_film_overlay_f.png"
        ,"silent_film_overlay_g.png"
        ,"silent_film_overlay_h.png"
        ,"silent_film_overlay_i.png"
        ,"silent_film_overlay_j.png"]
    
    let grainFilters320x240 = ["silent_film_overlay_a_320_240.png"
        ,"silent_film_overlay_b_320_240.png"
        ,"silent_film_overlay_c_320_240.png"
        ,"silent_film_overlay_d_320_240.png"
        ,"silent_film_overlay_e_320_240.png"
        ,"silent_film_overlay_f_320_240.png"
        ,"silent_film_overlay_g_320_240.png"
        ,"silent_film_overlay_h_320_240.png"
        ,"silent_film_overlay_i_320_240.png"
        ,"silent_film_overlay_j_320_240.png"]
    
    
    var grainImageFilter:[UIImage] = []
    
    var countGrainFilters = 0
    var progressTime = 0.0
    
    //MARK: - GPUImage variables
    var videoCamera: GPUImageVideoCamera
 
    var cropFilter:GPUImageFilter
    var colorFilter:GPUImageFilter
    var filter:GPUImageBrightnessFilter!
    var blendFilter:GPUImageNormalBlendFilter
    var writerMaskFilter: GPUImageFilter?

    var uiElementInput: GPUImageUIElement!
    var imageGrainView:UIImageView!
    
    var movieWriter:GPUImageMovieWriter!
    
    
    //MARK: - init
    required init(coder aDecoder: NSCoder)
    {
        videoCamera = GPUImageVideoCamera(sessionPreset: resolution, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait;
     
        cropFilter = GPUImageFilter()
        colorFilter = GPUImageFilter()
        filter = GPUImageBrightnessFilter()
        blendFilter = GPUImageNormalBlendFilter()
        
        pathToMergeMovie = ""
        
        progressTimer = NSTimer.init()
        
        mixpanel = Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
        
        super.init(coder: aDecoder)!
    }
    
    func configureView() {
        //Setup filters
        self.cropFilter = self.setCropFilter()
        self.colorFilter = self.setSepiaFilter()
        
        self.blendFilter.forceProcessingAtSize(blendProcessing!)
        
        //Timer
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.startUpdateGrainFilter()
            }
        }
        
        self.setUpFilters()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadGrainImages()
        
        shareButton.enabled = false
        
        videoProgress.transform = CGAffineTransformScale(videoProgress.transform, 1, 5)
        
        self.startTimeInActivityEvent()
        
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        Utils().debugLog("didReceiveMemoryWarning")
    }
    
    override func viewWillAppear(animated: Bool) {
        Utils().debugLog("MainViewController will willAppear")
        
        self.navigationController?.navigationBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        Utils().debugLog("MainViewController will dissappear")
        self.sendTimeInActivity()
        
        if(isRecording){
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                // do some task
                self.stopRecordVideo()
            }
        }
    }
    
    func loadGrainImages(){
        let filterArray:[AnyObject]?
        let deviceType = UIDevice.currentDevice().deviceType
        blendProcessing = CGSizeMake(320, 240)

        switch deviceType {
//        case (.IPad2 ):filterArray = grainFilters320x240
//            print("Ipad 2 ")
//        case (.IPad ):filterArray = grainFilters320x240
//            print("Ipad ")
            
        default: filterArray = grainFilters
            blendProcessing = CGSizeMake(640, 480)
            print("Default device 640*480 ")

        }
        
        for filter in filterArray!{
            let image = UIImage.init(named:filter as! String)
            self.grainImageFilter.append(image!)
        }
    }
    
    //MARK: - Button actions
    @IBAction func pushRearFrontCamera(sender: AnyObject) {
        self.changeCamera()
    }
    func changeCamera(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            self.videoCamera.rotateCamera()
            if self.isRearCamera {
                self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_CAMERA, result: "back");
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashButton.enabled = true
                    self.isRearCamera = false
                    self.rearFrontCameraButton.selected = false
                }
                
            }else{
                self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_CAMERA, result: "front");
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashButton.enabled = false
                    self.isRearCamera = true
                    self.rearFrontCameraButton.selected = true
                }
            }
        }
    }
    @IBAction func pushFlash(sender: AnyObject) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    sendUserInteractedTracking(AnalyticsConstants().CHANGE_FLASH, result: "false");
                    
                    device.torchMode = AVCaptureTorchMode.Off
                    flashButton.selected = false
                } else {
                    sendUserInteractedTracking(AnalyticsConstants().CHANGE_FLASH, result: "true");
                    
                    try device.setTorchModeOnWithLevel(1.0)
                    flashButton.selected = true
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func pushShareButton(sender: AnyObject) {
        //        self.mergeAudioVideo()
        self.showShareDialog()
        Utils().debugLog("Starts to merge with audio")
    }
    @IBAction func pushChangeBackground(sender: AnyObject) {
        if(backgroundChange==false){
            self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_SKIN, result: AnalyticsConstants().SKIN_WOOD);
            self.changeToLeatherSkin()
        }else{
            self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_SKIN, result: AnalyticsConstants().SKIN_LEATHER);
            self.changeToWoodSkin()
        }
    }
    
    @IBAction func pushRecord(sender: AnyObject) {
        if(!isRecording){
            self.pushStartRecording()
        }else{
            self.pushStopRecording()
        }
    }
    
    @IBAction func pushSetBWFilter(sender: AnyObject) {
        if(!self.BWFilterButton.selected){
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let filter = self.setBWFilter()
                self.replaceColorFilter(filter)
                
                //MIXPANEL
                self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_MONO, code: AnalyticsConstants().FILTER_CODE_MONO)
                dispatch_async(dispatch_get_main_queue()) {
                    self.disableOtherButtons(sender as! UIButton)
                    Utils().debugLog("Remove BWFilter")
                }
            }
        }
    }
    
    @IBAction func pushSetSepiaFilter(sender: AnyObject) {
        if(!self.sepiaFilterButton.selected){
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let filter = self.setSepiaFilter()
                self.replaceColorFilter(filter)
                
                //MIXPANEL
                self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_MONO, code: AnalyticsConstants().FILTER_CODE_MONO)
                dispatch_async(dispatch_get_main_queue()) {
                    self.disableOtherButtons(sender as! UIButton)
                    Utils().debugLog("Remove Sepia Filter")
                }
            }
        }
    }
    
    @IBAction func pushSetBlueFilter(sender: AnyObject) {
        if(!self.blueFilterButton.selected) {
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let filter = self.setBlueFilter()
                self.replaceColorFilter(filter)
                
                //MIXPANEL
                self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_MONO, code: AnalyticsConstants().FILTER_CODE_MONO)
                dispatch_async(dispatch_get_main_queue()) {
                    self.disableOtherButtons(sender as! UIButton)
                    Utils().debugLog("Remove blue filter")
                }
            }
        }
    }
    
    //MARK: - Thumbnail functions
    func setImageToThumbnail(){
        thumbnailImageView.hidden = false
        
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: videosArray[(videosArray.count - 1)]), options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        var cgImage:CGImage?
        do {
            cgImage =  try imgGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil)
            Utils().debugLog("Thumbnail image gets okay")
            
            // !! check the error before proceeding
            var thumbnail = UIImage(CGImage: cgImage!)
            settingsButton.layoutIfNeeded()
            let settingsButtonWidth = settingsButton.frame.width
            thumbnail = self.resizeImage(thumbnail, newWidth: settingsButtonWidth)
            // lay out this image view, or if it already exists, set its image property to uiImage
            
            thumbnailImageView.image = thumbnail
        } catch {
            Utils().debugLog("Thumbnail error \nSomething went wrong!")
        }
        
        if(videosArray.count>1){
            self.removeTextLayer()
        }
        
        self.setCornerToThumbnail()
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        image.drawInRect(CGRectMake(0, 0, newWidth, newWidth))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func setCornerToThumbnail(){
        cornerRadiusThumbnail = settingsButton.frame.width/2
        
        thumbnailImageView.layer.cornerRadius = cornerRadiusThumbnail
        thumbnailImageView.clipsToBounds = true
        
        //Set number on thumbnail
        
        let textLayer = self.getNumberThumbnailText()
        thumbnailImageView.layer.addSublayer(textLayer)
        
        let borderLayer = self.getBorderLayer()
        thumbnailImageView.layer.addSublayer(borderLayer)
    }
    
    func getNumberThumbnailText() -> CATextLayer{
        let textLayer = CATextLayer()
        
        textLayer.frame = CGRectMake(0,-5,thumbnailImageView.frame.size.width, thumbnailImageView.frame.size.height)
        
        let string = String(videosArray.count)
        textLayer.string = string
        
        let myFont = CTFontCreateWithName("Roboto-Regular", 8, nil)
        
        textLayer.font = myFont
        
        textLayer.foregroundColor = UIColor.init(red: (253/255), green: (171/255), blue: (83/255), alpha: 1).CGColor
        textLayer.wrapped = true
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.mainScreen().scale
        
        return textLayer
    }
    
    func getBorderLayer() -> CALayer{
        let borderLayer = CALayer.init()
        let borderFrame = CGRectMake(0,0,thumbnailImageView.frame.size.width, thumbnailImageView.frame.size.height)
        
        //Set properties border layer
        borderLayer.backgroundColor = UIColor.clearColor().CGColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = cornerRadiusThumbnail
        borderLayer.borderWidth = 3
        borderLayer.borderColor = UIColor.init(red: (253/255), green: (171/255), blue: (83/255), alpha: 1).CGColor
        
        return borderLayer
    }
    func removeTextLayer(){
        for layer in thumbnailImageView.layer.sublayers!{
            if layer.isKindOfClass(CATextLayer){
                layer.removeFromSuperlayer()
            }
        }
    }
    
    //MARK: - Functions
    
    //AlertView never used
    func alertviewTwoSeconds(title: String , message: String){
        let alert = UIAlertController(title: title , message: message, preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
        
        // Delay the dismissal by 5 seconds
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func showAlertVideoSave(title: String , message: String){
        //Shows an alertview at the bottom of the view and removes after 2 seconds
        
        let alert = UIAlertController(title: title , message: message, preferredStyle: .ActionSheet)
        
        alert.popoverPresentationController?.sourceView = self.view
        
        presentViewController(alert, animated: true, completion: nil)
        
        // Delay the dismissal by 5 seconds
        let delay = 0.8 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func stateShareAndSettingsButton(){
        if(isRecording){
            settingsButton.enabled = true
            shareButton.enabled = true
        }else{
            settingsButton.enabled = false
            shareButton.enabled = false
        }
    }
    
    //Reset values when comeBack from shareView
    func resetValues(){
        Utils().debugLog("Reset Values")
        
        self.waitingToMergeVideo = true
        self.videosArray.removeAll()
        pathToMovie = ""
        pathToMergeMovie = ""
        
        progressTime = 0.0
        for layer in thumbnailImageView.layer.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    
    func resetUIValues(){
        videoProgress.setProgress(0, animated: false)
        thumbnailImageView.hidden = true
        self.shareButton.enabled = false
        
        //Starts grain filter effect
        timer = NSTimer.scheduledTimerWithTimeInterval(graingImageTimeRefresh, target: self, selector: #selector(self.updateGrainImage), userInfo: nil, repeats: true)
    }
    
    //Choose only the filter who has tapped
    func disableOtherButtons(button: UIButton){
        //Disable all buttons
        BWFilterButton.selected = false
        sepiaFilterButton.selected = false
        blueFilterButton.selected = false
        
        //Enable selected button
        button.selected = true
    }
    
    //When video has saved in photoLibrary comes here
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            performSegueWithIdentifier("sharedView", sender: nil)
            Utils().debugLog("Save Successfully")
        } else {
            let title = "Save error"
            let message = error?.localizedDescription
            
            self.alertviewTwoSeconds(title, message: message!)
            Utils().debugLog("Save error")
        }
        waitingToMergeVideo = false //Stop waiting
    }
    
    //MARK: - Change background functions
    func changeToLeatherSkin(){
        //Change to leatherBackground
        let image : UIImage = UIImage(named:woodBackground)!
        backgroundImageView.image = image
        changeBackgroundButton.setImage(UIImage(named: leatherImageButton), forState:.Normal)
        
        backgroundChange=true
    }
    
    func changeToWoodSkin(){//Change to woodBackground
        let image : UIImage = UIImage(named:leatherBackground)!
        backgroundImageView.image = image
        changeBackgroundButton.setImage(UIImage(named: woodImageButton), forState:.Normal)
        
        backgroundChange=false
    }
    
    //MARK: - Filter Functions
    
    func startUpdateGrainFilter() {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(graingImageTimeRefresh, target: self, selector: #selector(self.updateGrainImage), userInfo: nil, repeats: true)
        
    }
    
    func setUpFilters(){
        
        self.removeFilterTargets()
        
        videoCamera.addTarget(cropFilter)
        
        cropFilter.addTarget(colorFilter)
        colorFilter.addTarget(filter)
        
        imageGrainView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
        
        imageGrainView.image = grainImageFilter[0]
        
        uiElementInput = GPUImageUIElement(view: imageGrainView)
        
        filter.addTarget(blendFilter)
        uiElementInput.addTarget(blendFilter)
      
        blendFilter.addTarget(filterView)
        
        filter.frameProcessingCompletionBlock = { filter, time in
            self.uiElementInput.update()
        }
        
        videoCamera.startCameraCapture()
        
        self.sendOutputToWriter()
    }
    
    func updateGrainImage(){
        let nGrainFilter = Int (arc4random_uniform(UInt32( grainFilters.count)))
        imageGrainView.image = grainImageFilter[nGrainFilter]
    }
    
    func sendOutputToWriter(){
        if(self.isRecording){
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.writerMaskFilter = self.setMaskFilter()
                
                self.blendFilter.addTarget(self.writerMaskFilter)
                self.writerMaskFilter!.addTarget(self.movieWriter)
            }
        }
    }
    
    func removeFilterTargets(){
        self.blendFilter.removeAllTargets()
        self.cropFilter.removeAllTargets()
        self.colorFilter.removeAllTargets()
    }
    
    //Replaces the actualFilter with the filter argument
    func replaceColorFilter(filter: GPUImageFilter){
        self.colorFilter = filter
        
        self.setUpFilters()

        Utils().debugLog("Filter changed")
    }
    
    //MARK: - SetUpFilters
    func setMaskFilter() -> GPUImageOpacityFilter{
        let filter = GPUImageOpacityFilter()
        filter.opacity = 0.0
        
        return filter
    }
    func setCropFilter() -> GPUImageFilter{
        //Crop the image to get 4:3 aspect ratio
        let filter:GPUImageCropFilter = GPUImageCropFilter.init(cropRegion: CGRectMake(0.0, 0.0, 1.0, 0.55 ))
        
        return filter
    }
    func setSepiaFilter() -> GPUImageFilter{
        let filter:GPUImageSepiaFilter = GPUImageSepiaFilter.init()
        filter.intensity=1;
        
        return filter
    }
    func setBlueFilter() -> GPUImageFilter{
        let filter:GPUImageMonochromeFilter = GPUImageMonochromeFilter.init()
        filter.setColorRed(0.44, green: 0.55, blue: 0.89)
        
        return filter
    }
    func setBWFilter() -> GPUImageFilter{
        let filter:GPUImageGrayscaleFilter = GPUImageGrayscaleFilter.init()
        
        return filter
    }
    
    //MARK: - Record Functions
    
    func pushStartRecording(){
        self.pathToMovie = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        self.pathToMovie = self.pathToMovie + "/\(Utils().giveMeTimeNow())kamarada.m4v"
        
        recordButton.selected = true
        
        recordVideo()
        
        self.sendOutputToWriter()

    }
    
    func pushStopRecording(){
        stopRecordVideo()
        recordButton.selected = false
    }
    
    func recordVideo(){
        mixpanel.timeEvent(AnalyticsConstants().VIDEO_RECORDED);
        self.sendUserInteractedTracking(AnalyticsConstants().RECORD, result: AnalyticsConstants().START);
        
        self.stateShareAndSettingsButton()
        
        let movieURL = NSURL.fileURLWithPath(pathToMovie)
        
        Utils().debugLog("PathToMovie: \(pathToMovie)")
        self.movieWriter = GPUImageMovieWriter.init(movieURL: movieURL, size: CGSizeMake(640,480))
        self.movieWriter.encodingLiveVideo = true
        
        self.movieWriter.startRecording()
        
        Utils().debugLog("Recording movie starts")
        
        isRecording = true
        
        //Start timer
        let videoStepDuration = videoDuration / progressSteps
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(videoStepDuration, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        
    }
    
    func updateProgressBar(){
        let delay = videoDuration/(progressSteps*Double(videoDuration))
        
        progressTime  += delay
        if(progressTime >= 1.0){
            videoProgress.setProgress(0.75, animated: false)
            progressTime = 0.75
        }else{
            videoProgress.setProgress(Float(progressTime), animated: true)
        }
    }
    
    func stopRecordVideo(){ //Stop Recording
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            Utils().debugLog("Starting to stop record video")
            
            
            self.videosArray.append(self.pathToMovie)
            
            self.writerMaskFilter!.removeAllTargets()
            
            self.videoCamera.audioEncodingTarget = nil
            
            self.movieWriter.finishRecordingWithCompletionHandler{ () -> Void in
                self.isRecording=false
                
                self.showAlertVideoSave("Video export", message: "Your clip has been saved into photogallery")
                
                Utils().debugLog("Stop recording video")
                
                self.saveClipToCameraRoll()
                self.movieWriter.endProcessing()
                self.movieWriter = nil
            }
        }
        self.shareButton.enabled = true
        
        //Stop progressview
        progressTimer.invalidate()
        
        //set thumbnail
        //Async thread to update UI
        dispatch_async(dispatch_get_main_queue()) {
            // update some UI
            self.stateShareAndSettingsButton()
            self.setImageToThumbnail()
        }
        
        //MIXPANEL
        self.setClipDuration()
        
        self.trackTotalVideosRecordedSuperProperty()
        self.sendVideoRecordedTracking()
        self.updateTotalVideosRecorded()
        self.sendUserInteractedTracking(AnalyticsConstants().RECORD, result: AnalyticsConstants().STOP);
    }
    
    //Merge videos in VideosArray and export to Documents folder and PhotoLibrary
    func mergeAudioVideo() {
        
        mixpanel.timeEvent(AnalyticsConstants().VIDEO_EXPORTED);
        timer?.invalidate()
        
        var videoTotalTime:CMTime = kCMTimeZero
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // 2 - Get Audio asset
        let audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kamarada_audio", ofType: "mp3")!)
        let audioAsset = AVAsset.init(URL: audioURL)
        // 3.1 - Video track
        let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo,
                                                                     preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        // 3 - Add assets to the composition
        for path in videosArray{
            // 2 - Get Video asset
            let videoURL: NSURL = NSURL.init(fileURLWithPath: path)
            let videoAsset = AVAsset.init(URL: videoURL)
            
            
            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                               ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] ,
                                               atTime: videoTotalTime)
                Utils().debugLog("el tiempo total del video es: \(videoTotalTime.seconds)")
                videoTotalTime = CMTimeAdd(videoTotalTime, videoAsset.duration)
            } catch _ {
                mixpanel.track(AnalyticsConstants().VIDEO_EXPORTED);
                Utils().debugLog("Error trying to create videoTrack")
            }
        }
        
        // 3.2 - Audio track
        let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTotalTime),
                                           ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0] ,
                                           atTime: kCMTimeZero)
        } catch _ {
            Utils().debugLog("Error trying to create audioTrack")
        }
        
        // 4 - Get path
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        self.pathToMergeMovie = (documentDirectory as NSString).stringByAppendingPathComponent("mergeKamaradaVideo-\(Utils().giveMeTimeNow()).m4v")
        let url = NSURL(fileURLWithPath: self.pathToMergeMovie)
        
        // 5 - Create Exporter
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = url
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter!.exportAsynchronouslyWithCompletionHandler() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.clipDuration = videoTotalTime.seconds
                Utils().debugLog("la duracion del clip es \(self.clipDuration)")
                
                self.sendExportedVideoMetadataTracking()
                self.saveMovieToCameraRoll()
            })
        }
    }
    
    func saveMovieToCameraRoll() {
        var videoAssetPlaceholder:PHObjectPlaceholder!
        
        //Save in to photoLibrary
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: self.pathToMergeMovie))
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
        }) { completed, error in
            if completed {
                Utils().debugLog("Video is saved!")
                //Create url to sharedView from PhotoLibrary
                let localID = videoAssetPlaceholder.localIdentifier
                let assetID =
                    localID.stringByReplacingOccurrencesOfString(
                        "/.*", withString: "",
                        options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let ext = "mp4"
                let assetURLStr =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                Utils().debugLog("assetURLstr \(assetURLStr)")
                
                //Assing urlToMergeMovieInPhotoLibrary to global variable.
                self.urlToMergeMovieInPhotoLibrary = NSURL.init(string: assetURLStr)
                
                
                self.waitingToMergeVideo = false //Stop waiting
                
                //Async thread to update UI
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.shareDialogController!.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.performSegueWithIdentifier("sharedView", sender: nil)
                    })
                }
            }
        }
    }
    
    
    func saveClipToCameraRoll() {
        Utils().debugLog("Save clip to Camera Roll")
        
        var videoAssetPlaceholder:PHObjectPlaceholder!
        
        //Save in to photoLibrary
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: self.pathToMovie))
            
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
        }) { completed, error in
            if completed {
                Utils().debugLog("Clip is saved!")
                //Create url to sharedView from PhotoLibrary
                let localID = videoAssetPlaceholder.localIdentifier
                let assetID =
                    localID.stringByReplacingOccurrencesOfString(
                        "/.*", withString: "",
                        options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let ext = "mp4"
                let assetURLStr =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                Utils().debugLog("assetURLstr \(assetURLStr)")
            }
        }
    }
    
    func showShareDialog(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        shareDialogController = storyboard.instantiateViewControllerWithIdentifier("shareDialog") as UIViewController
        
        self.navigationController?.definesPresentationContext = true
        
        shareDialogController?.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        shareDialogController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        
        self.presentViewController(shareDialogController!, animated: true, completion: nil)
    }
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        Utils().debugLog("prepareForSegue")
        
        if segue.identifier == "sharedView" {
            
            //Define next screen
            let controller = segue.destinationViewController as! SharedViewController
            
            //Set the values to the next screen
            
            if let detail:NSURL = self.urlToMergeMovieInPhotoLibrary{
                controller.movieURL = detail
                controller.moviePath  = pathToMergeMovie
                controller.numberOfClips = videosArray.count
                controller.backgroundImage = backgroundImageView.image!
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }else if segue.identifier == "settingsView" {
            self.sendUserInteractedTracking(AnalyticsConstants().INTERACTION_OPEN_SETTINGS, result: "");
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        Utils().debugLog("shouldPerformSegueWithIdentifier")
        
        var returned = false
        if identifier == "sharedView" {
            self.mergeAudioVideo()
            
            if !waitingToMergeVideo{
                
                returned = true
            }
        }else if identifier == "settingsView"{
            returned = true
        }
        return returned
    }
    
    //When you came from sharedViewController comes here
    @IBAction func backFromShareView(segue:UIStoryboardSegue) {
        Utils().debugLog("backFromShareView")
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            self.resetValues()
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.resetUIValues()
            }
        }
    }
    
    //MARK: - MIXPANEL
    //FOR VIPER: in Android this is in Activity.
    
    func sendUserInteractedTracking(interaction:String, result:String ) {
        //JSON properties
        let userInteractionsProperties =
            [
                AnalyticsConstants().ACTIVITY : String(object_getClass(self)),
                AnalyticsConstants().RECORDING: isRecording,
                AnalyticsConstants().INTERACTION: interaction,
                AnalyticsConstants().RESULT: result,
                ]
        mixpanel.track(AnalyticsConstants().USER_INTERACTED, properties: userInteractionsProperties as [NSObject : AnyObject])
    }
    
    func sendFilterSelectedTracking(name:String,code:String) {
        //JSON properties
        let userInteractionsProperties =
            [
                AnalyticsConstants().TYPE: AnalyticsConstants().TYPE_COLOR,
                AnalyticsConstants().NAME: name,
                AnalyticsConstants().CODE: code,
                AnalyticsConstants().RECORDING: isRecording,
                ]
        mixpanel.track(AnalyticsConstants().FILTER_SELECTED, properties: userInteractionsProperties as [NSObject : AnyObject])
    }
    
    //FOR VIPER: in Android this is in Presenter.
    func trackTotalVideosRecordedSuperProperty() {
        var numPreviousVideosRecorded:Int
        let properties = mixpanel.currentSuperProperties()
        
        if let prop = properties[AnalyticsConstants().TOTAL_VIDEOS_RECORDED]{
            numPreviousVideosRecorded = prop as! Int
        }else{
            numPreviousVideosRecorded = 0
        }
        
        numPreviousVideosRecorded += 1
        
        //JSON properties
        
        let totalVideoRecordedSuperProperty = [AnalyticsConstants().TOTAL_VIDEOS_RECORDED: numPreviousVideosRecorded]
        
        mixpanel.registerSuperProperties(totalVideoRecordedSuperProperty)
    }
    
    func sendVideoRecordedTracking() {
        //        let totalVideosRecorded = preferences.integerForKey(ConfigPreferences().TOTAL_VIDEOS_RECORDED)
        //JSON properties
        let videoRecordedProperties =
            [
                AnalyticsConstants().VIDEO_LENGTH: getClipDuration(),
                AnalyticsConstants().RESOLUTION: getResolution(),
                AnalyticsConstants().DOUBLE_HOUR_AND_MINUTES: Utils().getDoubleHourAndMinutes(),
                ]
        mixpanel.track(AnalyticsConstants().VIDEO_RECORDED, properties: videoRecordedProperties as [NSObject : AnyObject])
        self.updateUserProfileProperties()
    }
    
    func updateTotalVideosRecorded() {
        var numTotalVideosRecorded = preferences.integerForKey(ConfigPreferences().TOTAL_VIDEOS_RECORDED)
        numTotalVideosRecorded += 1
        
        preferences.setInteger(numTotalVideosRecorded, forKey: ConfigPreferences().TOTAL_VIDEOS_RECORDED)
    }
    
    func getClipDuration() -> Double{
        return clipDuration
    }
    
    func setClipDuration(){
        let videoURL: NSURL = NSURL.init(fileURLWithPath: pathToMovie!)
        let videoAsset = AVAsset.init(URL: videoURL)
        
        clipDuration = videoAsset.duration.seconds
        
        Utils().debugLog("Clip duration = \(clipDuration)")
    }
    func getResolution() -> String{
        return resolution
    }
    
    func updateUserProfileProperties() {
        Utils().debugLog("updateUserProfileProperties")
        mixpanel.identify(Utils().udid)
        
        var quality = ""
        
        if preferences.objectForKey(ConfigPreferences().QUALITY) == nil {
            //  Doesn't exist
        } else {
            quality = preferences.stringForKey(ConfigPreferences().QUALITY)!
        }
        //JSON properties
        let userProfileProperties =
            [
                AnalyticsConstants().RESOLUTION: resolution,
                AnalyticsConstants().QUALITY: quality,
                ]
        
        mixpanel.people.set(userProfileProperties)
        mixpanel.people.increment(AnalyticsConstants().TOTAL_VIDEOS_RECORDED,by: NSNumber.init(int: Int32(1)))
        mixpanel.people.set([AnalyticsConstants().LAST_VIDEO_RECORDED:Utils().giveMeTimeNow()])
        
    }
    func sendExportedVideoMetadataTracking() {
        let videoRecordedProperties =
            [
                AnalyticsConstants().VIDEO_LENGTH: getClipDuration(),
                AnalyticsConstants().RESOLUTION: getResolution(),
                AnalyticsConstants().NUMBER_OF_CLIPS: videosArray.count,
                AnalyticsConstants().DOUBLE_HOUR_AND_MINUTES: Utils().getDoubleHourAndMinutes(),
                ]
        mixpanel.track(AnalyticsConstants().VIDEO_EXPORTED, properties: videoRecordedProperties as [NSObject : AnyObject])
    }
    
    func startTimeInActivityEvent(){
        mixpanel.timeEvent(AnalyticsConstants().TIME_IN_ACTIVITY)
        Utils().debugLog("Sending startTimeInActivityEvent")
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

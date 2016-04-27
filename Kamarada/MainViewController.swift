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
    let cornerRadiusThumbnail:CGFloat = 20.0
    let videoDuration = 15.0
    let progressSteps = 400.0
    let resolution = AVCaptureSessionPreset640x480
    var clipDuration = 0.0
    let preferences = NSUserDefaults.standardUserDefaults()
    
    //MARK: - Variables
    var isRecording:Bool = false
    var isRearCamera:Bool = false
    var backgroundChange:Bool = false
    var waitingToMergeVideo:Bool = true
    
    var pathToMovie:String!
    var pathToMergeMovie:String
    var urlToMergeMovieInPhotoLibrary:NSURL!
    
    var videosArray:[String] = []
    var cola: NSOperationQueue
    
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
    
    var countGrainFilters = 0
    var progressTime = 0.0
    
    //MARK: - GPUImage variables
    var videoCamera: GPUImageVideoCamera
    var blendImage: GPUImagePicture?
    var cropFilter:GPUImageFilter
    var colorFilter:GPUImageFilter
    var filterGroup:GPUImageFilterGroup
    var movieWriter:GPUImageMovieWriter!
    
    //MARK: - Grain filter variables
    var testImage:UIImage!
    var blendFilter:GPUImageAlphaBlendFilter
    var imageSource:GPUImagePicture!
    
    //MARK: - init
    required init(coder aDecoder: NSCoder)
    {
        videoCamera = GPUImageVideoCamera(sessionPreset: resolution, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait;
        cropFilter = GPUImageFilter.init()
        colorFilter = GPUImageFilter.init()
        filterGroup = GPUImageFilterGroup.init()
        
        blendFilter = GPUImageAlphaBlendFilter.init()
        imageSource = GPUImagePicture.init()
        
        pathToMergeMovie = ""
        
        progressTimer = NSTimer.init()
        
        cola = NSOperationQueue.init()
        cola.maxConcurrentOperationCount = 1
        
        #if DEBUG
            mixpanel = Mixpanel.init(token: AnalyticsConstants().MIXPANEL_TOKEN, andFlushInterval: 2)
        #else
            mixpanel = Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
        #endif
        
        super.init(coder: aDecoder)!
    }
    
    var filterOperation: FilterOperationInterface? {
        didSet {
            //            self.configureView()
        }
    }
    
    func configureView() {
        //Setup filters
        cropFilter = setCropFilter()
        colorFilter = setSepiaFilter()
        
        videoCamera.addTarget(filterGroup)
        
        //Setup filterGroup
        filterGroup.addFilter(cropFilter)
        filterGroup.addFilter(colorFilter)
        
        cropFilter.addTarget(colorFilter)
        
        filterGroup.initialFilters = [ cropFilter ]
        filterGroup.terminalFilter = colorFilter
        
        //Grain filter
        testImage = UIImage.init(named: "silent_film_overlay_a.png")
        imageSource = GPUImagePicture.init(image: testImage, smoothlyScaleOutput: true)
        
        //Sources to blend filter
        filterGroup.addTarget(blendFilter, atTextureLocation: 0)
        imageSource.addTarget(blendFilter, atTextureLocation: 1)
        
        
        cola.addOperationWithBlock({
            self.imageSource.processImage()

            self.blendFilter.useNextFrameForImageCapture()
            self.blendFilter.addTarget(self.filterView)
            
            self.videoCamera.startCameraCapture()
        })
        
        //Timer
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.startUpdateGrainFilter()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        mixpanel.identify(mixpanel.distinctId);
        //        mixpanel.people.set([AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_PAID])
        //Search first launch, superproperty
        //        mixpanel.people.set([AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_PAID])
        //App use count
        //        mixpanel.people.set([AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_PAID])
        //LAN and LOCALE
        //        mixpanel.people.set([AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_PAID])
        // Superproperty app:Kamarada
        
        //App started
        //        TRACK
        // Do any additional setup after loading the view, typically from a nib.
        shareButton.enabled = false
        
        videoProgress.transform = CGAffineTransformScale(videoProgress.transform, 1, 5)
        
        self.navigationController?.navigationBar.hidden = true
        
        self.startTimeInActivityEvent()
        
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
       print("MainViewController will dissappear")
        self.sendTimeInActivity()
        
        if(isRecording){
            stopRecordVideo()
        }
    }
    
    //MARK: - Button actions
    @IBAction func pushRearFrontCamera(sender: AnyObject) {
        self.changeCamera()
    }
    func changeCamera(){
        videoCamera.rotateCamera()
        if isRearCamera {
            self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_CAMERA, result: "back");
            
            flashButton.enabled = true
            rearFrontCameraButton.selected = false
            isRearCamera = false
        }else{
            self.sendUserInteractedTracking(AnalyticsConstants().CHANGE_CAMERA, result: "front");
            
            flashButton.enabled = false
            rearFrontCameraButton.selected = true
            isRearCamera = true
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
        print("Starts to merge with audio")
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
        let filter = setBWFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove BWFilter")
        
        //MIXPANEL
        self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_MONO, code: AnalyticsConstants().FILTER_CODE_MONO)
        
    }
    
    @IBAction func pushSetSepiaFilter(sender: AnyObject) {
        let filter = setSepiaFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove Sepia Target")
        
        //MIXPANEL
        self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_SEPIA, code: AnalyticsConstants().FILTER_CODE_SEPIA)
    }
    @IBAction func pushSetBlueFilter(sender: AnyObject) {
        let filter = setBlueFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove cropFilter")
        
        //MIXPANEL
        self.sendFilterSelectedTracking(AnalyticsConstants().FILTER_NAME_AQUA, code: AnalyticsConstants().FILTER_CODE_AQUA)
    }
    
    //MARK: - Thumbnail functions
    func setImageToThumbnail(){
        thumbnailImageView.hidden = false
        
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: videosArray[(videosArray.count - 1)]), options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        var cgImage:CGImage?
        do {
            cgImage =  try imgGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil)
            print("Thumbnail image gets okay")
            
            // !! check the error before proceeding
            let thumbnail = UIImage(CGImage: cgImage!)
            // lay out this image view, or if it already exists, set its image property to uiImage
            
            thumbnailImageView.image = thumbnail
        } catch {
            print("Thumbnail error \nSomething went wrong!")
        }
        
        
        if(videosArray.count>1){
            self.removeTextLayer()
        }
        
        self.setCornerToThumbnail()
    }
    
    func setCornerToThumbnail(){
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
        print("Reset Values")
        
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
            print("Save Successfully")
        } else {
            let title = "Save error"
            let message = error?.localizedDescription
            
            self.alertviewTwoSeconds(title, message: message!)
            print("Save error")
        }
        waitingToMergeVideo = false //Stop waiting
    }
    
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
        
        NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: #selector(self.changeGrainFilter), userInfo: nil, repeats: true)
        
    }
    func updateCountGrainFilters() {
        if(countGrainFilters < (grainFilters.count - 1)){
            countGrainFilters += 1
        }else{
            countGrainFilters = 0
        }
    }
    
    func changeGrainFilter(){
        
        let image = UIImage.init(named:grainFilters[countGrainFilters])
        self.updateCountGrainFilters()
        videoCamera.addTarget(filterGroup)
        
        filterGroup.removeAllTargets()
        blendFilter.removeAllTargets()
        
        filterGroup.addFilter(cropFilter)
        filterGroup.addFilter(colorFilter)
        
        cropFilter.addTarget(colorFilter)
        
        filterGroup.initialFilters = [ cropFilter ]
        filterGroup.terminalFilter = colorFilter
        
        //Grain filter
        imageSource = GPUImagePicture.init(image: image, smoothlyScaleOutput: true)
        
        //Sources to blend filter
        filterGroup.addTarget(blendFilter, atTextureLocation: 0)
        imageSource.addTarget(blendFilter, atTextureLocation: 1)
        blendFilter.mix = 1.0
        
        cola.addOperationWithBlock({
            self.imageSource.processImage()
            
            self.blendFilter.useNextFrameForImageCapture()
            self.blendFilter.addTarget(self.filterView)
            
            self.videoCamera.startCameraCapture()
            
            if(self.isRecording){
                self.blendFilter.addTarget(self.movieWriter)
            }
        })
    }
    
    //Replaces the actualFilter with the filter argument
    func replaceColorFilter(filter: GPUImageFilter){
        cropFilter = setCropFilter()
        colorFilter = filter
        
        videoCamera.addTarget(filterGroup)
        
        filterGroup.removeAllTargets()
        blendFilter.removeAllTargets()
        
        filterGroup.addFilter(cropFilter)
        filterGroup.addFilter(colorFilter)
        
        cropFilter.addTarget(colorFilter)
        
        filterGroup.initialFilters = [ cropFilter ]
        filterGroup.terminalFilter = colorFilter
        
        //Grain filter
        testImage = UIImage.init(named: "silent_film_overlay_a.png")
        imageSource = GPUImagePicture.init(image: testImage, smoothlyScaleOutput: true)
        
        //Sources to blend filter
        filterGroup.addTarget(blendFilter, atTextureLocation: 0)
        imageSource.addTarget(blendFilter, atTextureLocation: 1)
        
        
        cola.addOperationWithBlock({
            self.imageSource.processImage()

            self.blendFilter.useNextFrameForImageCapture()
            self.blendFilter.addTarget(self.filterView)
            
            self.videoCamera.startCameraCapture()
            
            if(self.isRecording){
                self.blendFilter.addTarget(self.movieWriter)
            }
        })
        
        print("Filter changed")
    }
    
    //MARK: - SetUpFilters
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
        
        print("PathToMovie: \(pathToMovie)")
        self.movieWriter = GPUImageMovieWriter.init(movieURL: movieURL, size: CGSizeMake(640,480))
        self.movieWriter.encodingLiveVideo = true
        
        blendFilter.addTarget(self.movieWriter)
        self.movieWriter.startRecording()
        
        print("Recording movie starts")
        
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
        print("Starting to stop record video")
        
        self.stateShareAndSettingsButton()
        
        videosArray.append(pathToMovie)
        
        filterGroup.removeTarget(movieWriter)
        videoCamera.audioEncodingTarget = nil
        
        self.movieWriter.finishRecordingWithCompletionHandler{ () -> Void in
            self.isRecording=false
            
            print("Stop recording video")
            
            self.saveClipToCameraRoll()
        }
        self.shareButton.enabled = true
        
        //Stop progressview
        progressTimer.invalidate()
        
        //set thumbnail
        self.setImageToThumbnail()
        
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
                print("el tiempo total del video es: \(videoTotalTime.seconds)")
                videoTotalTime = CMTimeAdd(videoTotalTime, videoAsset.duration)
            } catch _ {
                mixpanel.track(AnalyticsConstants().VIDEO_EXPORTED);
                print("Error trying to create videoTrack")
            }
        }
        
        // 3.2 - Audio track
        let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTotalTime),
                                           ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0] ,
                                           atTime: kCMTimeZero)
        } catch _ {
            print("Error trying to create audioTrack")
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
                //                UISaveVideoAtPathToSavedPhotosAlbum(self.pathToMergeMovie, self,#selector(MainViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
                self.clipDuration = videoTotalTime.seconds
                print("la duracion del clip es \(self.clipDuration)")
                
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
                print("Video is saved!")
                //Create url to sharedView from PhotoLibrary
                let localID = videoAssetPlaceholder.localIdentifier
                let assetID =
                    localID.stringByReplacingOccurrencesOfString(
                        "/.*", withString: "",
                        options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let ext = "mp4"
                let assetURLStr =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                print("assetURLstr \(assetURLStr)")
                
                //Assing urlToMergeMovieInPhotoLibrary to global variable.
                self.urlToMergeMovieInPhotoLibrary = NSURL.init(string: assetURLStr)
                
                
                self.waitingToMergeVideo = false //Stop waiting
                
                //Async thread to update UI
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.performSegueWithIdentifier("sharedView", sender: nil)
                }
            }
        }
    }
    
    
    func saveClipToCameraRoll() {
        print("Save clip to Camera Roll")

        var videoAssetPlaceholder:PHObjectPlaceholder!
        
        //Save in to photoLibrary
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: self.pathToMovie))
            
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
        }) { completed, error in
            if completed {
                print("Clip is saved!")
                //Create url to sharedView from PhotoLibrary
                let localID = videoAssetPlaceholder.localIdentifier
                let assetID =
                    localID.stringByReplacingOccurrencesOfString(
                        "/.*", withString: "",
                        options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let ext = "mp4"
                let assetURLStr =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                print("assetURLstr \(assetURLStr)")
            }
        }
    }
    
    //MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("prepareForSegue")
        
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
        var returned = false
        if identifier == "sharedView" {
            self.mergeAudioVideo()
            //Set the values to the next screen
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
        print("backFromShareView")
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
        
        print("Clip duration = \(clipDuration)")
    }
    func getResolution() -> String{
        return resolution
    }
    
    func updateUserProfileProperties() {
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
        mixpanel.people.increment(AnalyticsConstants().TOTAL_VIDEOS_RECORDED,by: 1)
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
        print("Sending startTimeInActivityEvent")
 }
    func sendTimeInActivity() {
        print("Sending AnalyticsConstants().TIME_IN_ACTIVITY")
        //NOT WORKING -- falta el comienzo time_event para arrancar el contador
        
        let whatClass = String(object_getClass(self))
        print("what class is \(whatClass)")
        
        let viewProperties = [AnalyticsConstants().ACTIVITY:whatClass]
        mixpanel.track(AnalyticsConstants().TIME_IN_ACTIVITY, properties: viewProperties)
        mixpanel.flush()
    }
}

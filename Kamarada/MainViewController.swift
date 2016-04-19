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

class MainViewController: UIViewController {
    
    //MARK: - Background constants
    let woodBackground = "activity_record_background_wood.png"
    let leatherBackground = "activity_record_background_leather.png"
    
    let woodImageButton = "activity_record_skin_wood_icon_normal.png"
    let leatherImageButton = "activity_record_skin_leather_icon_normal.png"
    
    //MARK: - Outlets
    
    //Views
    @IBOutlet weak var backgroundImage: UIImageView!
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
    
    //MARK: - Variables
    var isRecording:Bool = false
    var isRearCamera:Bool = false
    var backgroundChange:Bool = false
    var waitingToMergeVideo:Bool = true
    
    var pathToMovie:String!
    var pathToMergeMovie:String
    var urlToMergeMovieInPhotoLibrary:NSURL!
    
    var videosArray:[String] = []
    
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
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait;
        cropFilter = GPUImageFilter.init()
        colorFilter = GPUImageFilter.init()
        filterGroup = GPUImageFilterGroup.init()
        
        blendFilter = GPUImageAlphaBlendFilter.init()
        imageSource = GPUImagePicture.init()
        
        pathToMergeMovie = ""
        
        progressTimer = NSTimer.init()
        
        super.init(coder: aDecoder)!
    }
    
    var filterOperation: FilterOperationInterface? {
        didSet {
            self.configureView()
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
        
        imageSource.processImage()
        
        blendFilter.useNextFrameForImageCapture()
        blendFilter.addTarget(filterView)
        
        videoCamera.startCameraCapture()
        
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
        // Do any additional setup after loading the view, typically from a nib.
        shareButton.enabled = false
        
        
        videoProgress.transform = CGAffineTransformScale(videoProgress.transform, 1, 5)
        
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button actions
    @IBAction func pushRearFrontCamera(sender: AnyObject) {
        videoCamera.rotateCamera()
        if isRearCamera {
            flashButton.enabled = true
            rearFrontCameraButton.selected = false
            isRearCamera = false
        }else{
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
                    device.torchMode = AVCaptureTorchMode.Off
                    flashButton.selected = false
                } else {
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
        if(backgroundChange==false){//Change to leatherBackground
            let image : UIImage = UIImage(named:woodBackground)!
            backgroundImage.image = image
            changeBackgroundButton.setImage(UIImage(named: leatherImageButton), forState:.Normal)
            
            backgroundChange=true
        }else{//Change to woodBackground
            let image : UIImage = UIImage(named:leatherBackground)!
            backgroundImage.image = image
            changeBackgroundButton.setImage(UIImage(named: woodImageButton), forState:.Normal)
            
            backgroundChange=false
        }
    }
    
    @IBAction func pushRecord(sender: AnyObject) {
        if(!isRecording){
            self.pathToMovie = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            self.pathToMovie = self.pathToMovie + "/\(giveMeTimeNow())kamarada.m4v"
            
            recordButton.selected = true
            
            recordVideo()
        }else{
            stopRecordVideo()
            recordButton.selected = false
        }
    }
    
    @IBAction func pushSetBWFilter(sender: AnyObject) {
        let filter = setBWFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove BWFilter")
    }
    
    @IBAction func pushSetSepiaFilter(sender: AnyObject) {
        let filter = setSepiaFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove Sepia Target")
    }
    @IBAction func pushSetBlueFilter(sender: AnyObject) {
        let filter = setBlueFilter()
        self.replaceColorFilter(filter)
        
        disableOtherButtons(sender as! UIButton)
        print("Remove cropFilter")
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
        
        imageSource.processImage()
        
        blendFilter.useNextFrameForImageCapture()
        blendFilter.addTarget(filterView)
        
        videoCamera.startCameraCapture()
        
        if(isRecording){
            blendFilter.addTarget(movieWriter)
        }
        
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
        
        imageSource.processImage()
        
        blendFilter.useNextFrameForImageCapture()
        blendFilter.addTarget(filterView)
        
        videoCamera.startCameraCapture()
        
        if(isRecording){
            blendFilter.addTarget(movieWriter)
        }
        
        print("Filter changed")
    }
    
    //MARK: - SetUpFilters
    func setCropFilter() -> GPUImageFilter{
        //Crop the image to get 4:3 aspect ratio
        let filter:GPUImageCropFilter = GPUImageCropFilter.init(cropRegion: CGRectMake(0.0, 0.0, 1.0, 0.75 ))
        
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
    
    func recordVideo(){
        self.stateShareAndSettingsButton()
        
        let movieURL = NSURL.fileURLWithPath(pathToMovie)
        
        print("PathToMovie: \(pathToMovie)")
        self.movieWriter = GPUImageMovieWriter.init(movieURL: movieURL, size: CGSizeMake(640,480))
        self.movieWriter.encodingLiveVideo = true
        
        blendFilter.addTarget(self.movieWriter)
        self.movieWriter.startRecording()
        
        print("Recording movie starts")
        
        isRecording=true
        
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
        self.stateShareAndSettingsButton()
        
        videosArray.append(pathToMovie)
        
        filterGroup.removeTarget(movieWriter)
        videoCamera.audioEncodingTarget = nil
        
        self.movieWriter.finishRecordingWithCompletionHandler{ () -> Void in
            self.isRecording=false
            
            print("Stop recording video")
        }
        self.shareButton.enabled = true
        
        //Stop progressview
        progressTimer.invalidate()
        
        //set thumbnail
        self.setImageToThumbnail()
    }
    
    //Merge videos in VideosArray and export to Documents folder and PhotoLibrary
    func mergeAudioVideo() {
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
        self.pathToMergeMovie = (documentDirectory as NSString).stringByAppendingPathComponent("mergeKamaradaVideo-\(giveMeTimeNow()).m4v")
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
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("prepareForSegue to share")
        
        if segue.identifier == "sharedView" {
            //Define next screen
            let controller = segue.destinationViewController as! SharedViewController
            
            //Set the values to the next screen
            
            if let detail:NSURL = self.urlToMergeMovieInPhotoLibrary{
                controller.movieURL = detail
                controller.moviePath  = pathToMergeMovie
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
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
    
    //MARK: - TEST
    
}

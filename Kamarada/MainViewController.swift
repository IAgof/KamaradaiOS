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
    
    //MARK: - Variables
    var isRecording:Bool = false
    var isRearCamera:Bool = false
    var backgroundChange:Bool = false
    var waitingToMergeVideo:Bool = true
    
    var pathToMovie:String!
    var pathToMergeMovie:String
    
    var videosArray:[String] = []
    
    //MARK: - GPUImage variables
    var videoCamera: GPUImageVideoCamera
    var blendImage: GPUImagePicture?
    var cropFilter:GPUImageFilter
    var colorFilter:GPUImageFilter
    var filterGroup:GPUImageFilterGroup
    var movieWriter:GPUImageMovieWriter!
    
    //MARK: - init
    required init(coder aDecoder: NSCoder)
    {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait;
        cropFilter = GPUImageFilter.init()
        colorFilter = GPUImageFilter.init()
        filterGroup = GPUImageFilterGroup.init()
        
        pathToMergeMovie = ""
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
        
        filterGroup.addTarget(filterView)
        
        videoCamera.startCameraCapture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        shareButton.enabled = false

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
        self.waitingToMergeVideo = true
        self.videosArray.removeAll()
        pathToMovie = ""
        pathToMergeMovie = ""
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
    
    //Replaces the actualFilter with the filter argument
    func replaceColorFilter(filter: GPUImageFilter){
        cropFilter = setCropFilter()
        colorFilter = filter
        
        videoCamera.addTarget(filterGroup)
        
        filterGroup.removeAllTargets()
        
        filterGroup.addFilter(cropFilter)
        filterGroup.addFilter(colorFilter)
        
        cropFilter.addTarget(colorFilter)
        
        filterGroup.initialFilters = [ cropFilter ]
        filterGroup.terminalFilter = colorFilter
        
        filterGroup.addTarget(filterView)
        if(isRecording){
            filterGroup.addTarget(movieWriter)
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
        
        filterGroup.addTarget(self.movieWriter)
        self.movieWriter.startRecording()
        
        print("Recording movie starts")
        
        isRecording=true
    }
    
    func stopRecordVideo(){ //Stop Recording
        self.stateShareAndSettingsButton()
        
        videosArray.append(pathToMovie)
        
        filterGroup.removeTarget(movieWriter)
        videoCamera.audioEncodingTarget = nil
        self.movieWriter.finishRecordingWithCompletionHandler{ () -> Void in
            self.isRecording=false
            
            print("Record Movie Completed")
        }
        self.shareButton.enabled = true
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
                UISaveVideoAtPathToSavedPhotosAlbum(self.pathToMergeMovie, self,#selector(MainViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
            })
        }
    }
    
    //MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        print("prepareForSegue to share")
        
        if segue.identifier == "sharedView" {
            //Define next screen
            let controller = segue.destinationViewController as! SharedViewController
            
            //Set the values to the next screen
            
            if let detail:String = self.pathToMergeMovie{
                controller.sharedVideoPath = detail
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
        print("Reset Values")
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            self.resetValues()
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.shareButton.enabled = false
            }
        }
    }
}

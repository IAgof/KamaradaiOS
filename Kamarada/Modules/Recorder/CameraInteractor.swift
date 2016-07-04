//
//  CameraInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 25/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage
import AVFoundation
import AVKit

class CameraInteractor:CameraRecorderDelegate,
                    CameraInteractorInterface{
    //MARK: - VIPER
    var cameraDelegate:CameraInteractorDelegate
    var cameraRecorder = CameraRecorderInteractor()
    
    //MARK: - Camera variables
    var videoCamera:GPUImageVideoCamera
    var filter:GPUImageFilter
    var maskFilterInput:GPUImageFilter
    var maskFilterOutput:GPUImageFilter
    var displayView: GPUImageView
    var sourceImageGPUUIElement: GPUImageUIElement?
    var imageView:UIImageView
    var waterMark:GPUImagePicture = GPUImagePicture()
    var maskFilterToRecord = GPUImageFilter()
        
    var cameraResolution = CameraResolution.init(AVResolution: "")

    var isFrontCamera:Bool = false
    
    var timer:NSTimer? = nil
    
    let graingImageTimeRefresh = 0.20
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
    
    var grainImageFilter:[UIImage] = []
    var blendProcessing :CGSize?
    

    var isRecording: Bool = false{
        didSet {
            if isRecording {
                self.setInputToWriter()
            }else{
                self.stopRecordVideo()
            }
        }
    }
    
    //MARK: - Init
    required init(display:GPUImageView, cameraDelegate: CameraInteractorDelegate){
        self.cameraDelegate = cameraDelegate

        videoCamera = GPUImageVideoCamera(sessionPreset: cameraResolution.rearCameraResolution, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait
        displayView = display
        imageView = UIImageView.init(frame: displayView.frame)
        
        filter = GPUImageFilter()
        maskFilterInput = GPUImageFilter()
        maskFilterOutput = GPUImageFilter()
        let cropfilter =  GPUImageCropFilter.init(cropRegion: CGRectMake(0.0, 0.0, 1.0, 0.55 ))
        
        videoCamera.addTarget(cropfilter)

        cropfilter.addTarget(filter)
        
        self.addBlendFilterAtInit()
        
        videoCamera.startCameraCapture()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraInteractor.checkOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        
        self.loadGrainImages()
        
        dispatch_async(dispatch_get_main_queue()) {
            // update some UI
            self.startUpdateGrainFilter()
        }
        self.addFilter(GPUImageSepiaFilter())
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
    
    func startUpdateGrainFilter() {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(graingImageTimeRefresh, target: self, selector: #selector(self.updateGrainImage), userInfo: nil, repeats: true)
        
    }
    @objc func updateGrainImage(){
        let nGrainFilter = Int (arc4random_uniform(UInt32( grainFilters.count)))
        imageView.image = grainImageFilter[nGrainFilter]
    }

    func getClipsArray() -> [String] {
        return cameraRecorder.getClipsArray()
    }
    
    func resetClipsArray(){
        cameraRecorder.resetClipsArray()
    }
    
    //MARK: - Orientation
    @objc func checkOrientation(){
        if !isRecording {
            switch UIDevice.currentDevice().orientation{
            case .Portrait,.PortraitUpsideDown:
                print("Check Orientation: \(UIDevice.currentDevice().orientation)")
            case .LandscapeLeft:
                videoCamera.outputImageOrientation = .LandscapeRight
                break
            case .LandscapeRight:
                videoCamera.outputImageOrientation = .LandscapeLeft
                break
            default:
                break
            }
        }
    }
    
    func rotateCamera(){
        
        if self.isFrontCamera {
            self.videoCamera.rotateCamera()

            self.isFrontCamera = false
            setResolution()
            cameraDelegate.cameraRear()
        }else{
            self.isFrontCamera = true
            cameraDelegate.cameraFront()
            self.videoCamera.horizontallyMirrorFrontFacingCamera = true
            if(FlashInteractor().isFlashTurnOn()){
                cameraDelegate.flashOff()
            }
            setResolution()
            self.videoCamera.rotateCamera()
        }
    }
    
    //MARK: - Filters functions
    func addBlendFilterAtInit(){
        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.mix = 0.5
        filter.removeAllTargets()
        
        let image = UIImage.init(named: "filter_free")
        imageView.image = image
        
        sourceImageGPUUIElement = GPUImageUIElement(view: imageView)
        
        filter.addTarget(blendFilter)
        sourceImageGPUUIElement!.addTarget(blendFilter)
        
        blendFilter.addTarget(maskFilterInput)
        
        maskFilterInput.addTarget(maskFilterOutput)
        
        maskFilterOutput.addTarget(displayView)
        
        filter.frameProcessingCompletionBlock = { filter, time in
            self.sourceImageGPUUIElement!.update()
        }
    }
    
    func changeBlendImage(image:UIImage){
        imageView.image = image
    }
    
    func changeFilter(newFilter:GPUImageFilter){
        ChangeFilterInteractor().changeFilter(maskFilterInput, newFilter: newFilter, display: displayView)
        
        maskFilterOutput = newFilter
        if isRecording {
            setInputToWriter()
        }
    }
    
    func addFilter(newFilter:GPUImageFilter){
        AddFilterInteractor().addFilter(maskFilterInput, newFilter: newFilter, display: displayView)
        
        maskFilterOutput = newFilter
    }
    
    func removeFilters(){
        RemoveFilterInteractor().removeFilter(maskFilterInput, imageView: imageView, display: displayView)
        
        self.reSetOutputIfIsRecording()
    }
    
    func removeShaders(){
        RemoveFilterInteractor().removeShader(maskFilterInput, display: displayView)
        
        self.reSetOutputIfIsRecording()
    }
    
    func reSetOutputIfIsRecording() {
        maskFilterOutput = GPUImageFilter()
        
        maskFilterInput.addTarget(maskFilterOutput)
        
        maskFilterOutput.addTarget(displayView)
        
        if isRecording {
            setInputToWriter()
        }
    }
    
    func removeOverlay(){
        RemoveFilterInteractor().removeOverlay(imageView)
    }

    func setInputToWriter(){
        
        print("set Input To Writer")
        
        print("\n maskFilterOutput targets \n \(maskFilterOutput.targets())\n\n\n")
        
        maskFilterToRecord = GPUImageFilter()
        
        maskFilterOutput.addTarget(maskFilterToRecord)
        
        cameraRecorder.setInput(maskFilterToRecord)
    }
    
    //MARK: - Recorder delegate
    func startRecordVideo(completion:(String)->Void){
        print("Start record video")
        
        cameraRecorder.setVideoCamera(videoCamera)
        cameraRecorder.setResolution(cameraResolution.rearCameraResolution)
        
        cameraRecorder.recordVideo({answer in
            print("Camera Interactor \(answer)")
            completion(answer)
        })
    }
    
    func stopRecordVideo() {
        for maskFilter in maskFilterOutput.targets(){
            if maskFilter.isKindOfClass(GPUImageFilter){
                maskFilterOutput.removeTarget(maskFilter as! GPUImageInput)
            }
        }
        cameraRecorder.stopRecordVideo({duration in
            Utils().debugLog("Answer from record interactor:  duration-\(duration)")
            self.cameraDelegate.trackVideoRecorded(duration)
        })
    }
    
    //MARK: - Event handler
    func setIsRecording(isRecording:Bool){
        self.isRecording = isRecording
    }
    
    func cameraViewTapAction(tapDisplay:UIGestureRecognizer){
        
        if (tapDisplay.state == UIGestureRecognizerState.Recognized) {
            var location = tapDisplay.locationInView(self.displayView)
            
            let device = videoCamera.inputCamera
            do {
                try device.lockForConfiguration()
                
            }catch{
                return
            }
            var pointOfInterest = CGPointMake(0.5, 0.5)
            let frameSize = self.displayView.frame.size
            
            if (videoCamera.cameraPosition() == AVCaptureDevicePosition.Front) {
                location.x = frameSize.width - location.x;
            }
            
            pointOfInterest = CGPointMake(location.y / frameSize.height, 1.0 - (location.x / frameSize.width));
            
            
            if (device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus)) {
                device.focusPointOfInterest = pointOfInterest
                device.focusMode = AVCaptureFocusMode.AutoFocus
                
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) {
                    device.exposurePointOfInterest = pointOfInterest
                    device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                }
                device.unlockForConfiguration()
                
            }
        }
    }
    
    func zoom(pinch: UIPinchGestureRecognizer) {
        var device: AVCaptureDevice = self.videoCamera.inputCamera
        var vZoomFactor = (pinch.scale)
        let pinchVelocityDividerFactor:Float = 50//To change velocity of zoom
        
        var error:NSError!
        do{
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            
            if (vZoomFactor < device.activeFormat.videoMaxZoomFactor){
                let desiredZoomFactor = device.videoZoomFactor + CGFloat.init( atan2f(Float(pinch.velocity), pinchVelocityDividerFactor))
                // Check if desiredZoomFactor fits required range from 1.0 to activeFormat.videoMaxZoomFactor
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, device.activeFormat.videoMaxZoomFactor));
                
            }else{
                NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, vZoomFactor);
            }
        }catch error as NSError{
            NSLog("Unable to set videoZoom: %@", error.localizedDescription);
        }catch _{
            
        }
    }
    
    func setResolution(){
        //Get resolution
        if let getFromDefaultResolution = NSUserDefaults.standardUserDefaults().stringForKey(SettingsConstants().SETTINGS_RESOLUTION){
            cameraResolution = CameraResolution.init(AVResolution: getFromDefaultResolution)
        }else{
            cameraResolution = CameraResolution.init(AVResolution: "")
        }
        
        //Set resolution
        if isFrontCamera {
            if UIDevice.currentDevice().model == "iPhone4,1" {
                
            }else{
                videoCamera.captureSessionPreset = cameraResolution.frontCameraResolution
            }
        }else{
            videoCamera.captureSessionPreset = cameraResolution.rearCameraResolution
        }
    }
}
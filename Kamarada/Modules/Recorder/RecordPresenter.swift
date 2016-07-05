//
//  RecordPresenter.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

class RecordPresenter: NSObject
    , RecordPresenterInterface
    ,CameraInteractorDelegate{
    
    //MARK: - Variables VIPER
    var controller: RecordController?
    var recordWireframe: RecordWireframe?
    var settingsWireframe: SettingsWireframe?
    var shareWireframe: ShareWireframe?
    var cameraInteractor: CameraInteractor?
    var timerInteractor: TimerInteractor?

    //MARK: - Variables
    var isRecording = false

    struct EffectOnView {
        var effectName:String
        var effectActive:Bool
    }
    
    //MARK: - Record Presenter Interface
    func viewDidLoad(displayView:GPUImageView){
        
        controller?.configureView()
        cameraInteractor = CameraInteractor(display: displayView,cameraDelegate: self)
    }
    
    func viewWillDisappear() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if self.isRecording{
                self.stopRecord()
            }
            FlashInteractor().turnOffWhenViewWillDissappear()
            dispatch_async(dispatch_get_main_queue(), {
                self.controller?.showFlashOn(false)
            })
        })
    }
    
    func viewWillAppear() {

    }
    
    func pushSettings() {
        print("Record presenter pushSettings")
        self.trackSettingsPushed()
        settingsWireframe?.presentSettingsInterfaceFromViewController(controller!)
    }
    
    func pushShare() {
        controller?.createAlertWaitToExport()
        controller?.getTrackerObject().mixpanel.timeEvent(AnalyticsConstants().VIDEO_EXPORTED);
        
        print("Record presenter pushShare")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let exporter = ExporterInteractor.init(videosArray: (self.cameraInteractor?.getClipsArray())!)
            exporter.exportVideos({ exportPath,videoTotalTime in
                print("Export path response = \(exportPath)")
                self.trackExported(videoTotalTime)
                
                self.controller?.dissmissAlertWaitToExport({
                    //wait to remove alert to present new Screeen
                    self.shareWireframe?.presentShareInterfaceFromViewController(self.controller!,
                        videoPath: exportPath,
                        numberOfClips: (self.cameraInteractor?.getClipsArray().count)!)
                })
            })
        });
    }
    
    func pushFlash() {
        let flashState = FlashInteractor().switchFlashState()
        controller?.showFlashOn(flashState)
        self.trackFlash(flashState)
    }
    
    func pushRecord() {
        if isRecording {
            self.stopRecord()
        }else{
            self.startRecord()
        }
    }
    
    func pushSepiaFilter() {
        cameraInteractor?.changeFilter(GPUImageSepiaFilter())
        
        self.disableOtherButtons()
        controller?.selectSepiaButton()
    }
    
    func pushBlueFilter() {
        let filter = GPUImageMonochromeFilter()
        filter.setColorRed(0.44, green: 0.55, blue: 0.89)

        cameraInteractor?.changeFilter(filter)
        
        self.disableOtherButtons()
        controller?.selectBlueButton()
    }
    
    func pushBWFilter() {
        cameraInteractor?.changeFilter(GPUImageGrayscaleFilter())
        
        self.disableOtherButtons()
        controller?.selectBWButton()
    }
    
    func pushRotateCamera() {
        cameraInteractor!.rotateCamera()
    }
    
    func disableOtherButtons(){
        //Disable all buttons
        controller?.unselectBlueButton()
        controller?.unselectSepiaButton()
        controller?.unselectBWButton()
    }
    
    func resetRecorder() {
        controller?.hideRecordedVideoThumb()
        controller?.disableShareButton()
        
        cameraInteractor?.resetClipsArray()
    }
    
    func displayHasTapped(tapGesture:UIGestureRecognizer){
        cameraInteractor?.cameraViewTapAction(tapGesture)
    }
    
    func displayHasPinched(pinchGesture: UIPinchGestureRecognizer) {
        cameraInteractor?.zoom(pinchGesture)
    }
    
    
    
    //MARK: - Start/Stop Record
    func startRecord(){
        self.trackStartRecord()
        
        controller?.recordButtonEnable(false)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.cameraInteractor?.setIsRecording(true)
            
            self.cameraInteractor?.startRecordVideo({answer in
                print("Record Presenter \(answer)")
                self.controller?.recordButtonEnable(true)
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                // update some UI
                self.controller?.showRecordButton()
                self.controller?.disableShareButton()
            })
        })
        isRecording = true
        
    }
    
    func stopRecord(){
        self.trackStopRecord()
        
        isRecording = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // do some task
            self.cameraInteractor?.setIsRecording(false)
            
            let videosArray = self.cameraInteractor?.getClipsArray()
            let thumb = ThumbnailInteractor.init(videosArray: videosArray!).getThumbnailImageView()
            dispatch_async(dispatch_get_main_queue(), {
                // update some UI
                self.controller?.showRecordedVideoThumb(thumb)
                self.controller?.showNumberVideos((videosArray?.count)!)
                self.controller?.showStopButton()
                self.controller?.enableShareButton()
            });
        });
        
    }
    //MARK: - Track Events
    func trackFlash(flashState:Bool){
        let tracker = controller?.getTrackerObject()
        if flashState {
            tracker?.sendUserInteractedTracking((controller?.getControllerName())!,
                                                recording: isRecording,
                                                interaction:AnalyticsConstants().CHANGE_FLASH,
                                                result: "true")
        }else{
            tracker?.sendUserInteractedTracking((controller?.getControllerName())!,
                                                recording: isRecording,
                                                interaction:AnalyticsConstants().CHANGE_FLASH,
                                                result: "false")
        }
    }
    
    func trackFrontCamera(){
        controller?.getTrackerObject().sendUserInteractedTracking((controller?.getControllerName())!,
                                                                  recording: isRecording,
                                                                  interaction:  AnalyticsConstants().CHANGE_CAMERA,
                                                                  result: AnalyticsConstants().CAMERA_FRONT)
    }
    
    func trackRearCamera(){
        controller?.getTrackerObject().sendUserInteractedTracking((controller?.getControllerName())!,
                                                                  recording: isRecording,
                                                                  interaction:  AnalyticsConstants().CHANGE_CAMERA,
                                                                  result: AnalyticsConstants().CAMERA_BACK)
    }
    
    func trackStartRecord(){
        controller?.getTrackerObject().mixpanel.timeEvent(AnalyticsConstants().VIDEO_RECORDED);

        controller?.getTrackerObject().sendUserInteractedTracking((controller?.getControllerName())!,
                                                                  recording: isRecording,
                                                                  interaction:  AnalyticsConstants().RECORD,
                                                                  result: AnalyticsConstants().START)
    }
    
    func trackExported(videoTotalTime:Double) {
        self.controller?.getTrackerObject().sendExportedVideoMetadataTracking(videoTotalTime,
                                                                              numberOfClips: (self.cameraInteractor?.getClipsArray().count)!)
    }
    
    func trackStopRecord(){
        controller?.getTrackerObject().sendUserInteractedTracking((controller?.getControllerName())!,
                                                                  recording: isRecording,
                                                                  interaction:  AnalyticsConstants().RECORD,
                                                                  result: AnalyticsConstants().STOP)
    }
    
    func trackSettingsPushed() {
        controller?.getTrackerObject().sendUserInteractedTracking((controller?.getControllerName())!,
                                                                  recording: isRecording,
                                                                  interaction:  AnalyticsConstants().INTERACTION_OPEN_SETTINGS,
                                                                  result: "")
    }
    
//    func trackFilterSelected(name:String) {
//        let filter = EffectProvider().getFilterByName(name)
//        controller?.getTrackerObject().sendFilterSelectedTracking(filter.getType(),
//                                                                  name: filter.getName().lowercaseString,
//                                                                  code: filter.getIdentifier().lowercaseString,
//                                                                  isRecording: isRecording,
//                                                                  combined: isFiltersCombined(),
//                                                                  filtersCombined: getFiltersActive())
//    }
    
    
    //MARK: - Camera delegate
    func trackVideoRecorded(videoLenght:Double) {
        controller?.getTrackerObject().trackTotalVideosRecordedSuperProperty()
        controller?.getTrackerObject().sendVideoRecordedTracking(videoLenght)
        controller?.getTrackerObject().updateTotalVideosRecorded()
    }
    
    func flashOn() {
        controller?.showFlashOn(true)
    }
    
    
    func flashOff() {
        controller?.showFlashOn(false)
    }
    
    func cameraRear() {
        controller?.showBackCameraSelected()
        self.trackRearCamera()
        controller?.showFlashSupported(true)
    }
    
    func cameraFront() {
        controller?.showFrontCameraSelected()
        self.trackFrontCamera()
        controller?.showFlashSupported(false)
    }
}
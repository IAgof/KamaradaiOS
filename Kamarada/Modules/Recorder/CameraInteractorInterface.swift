//
//  CameraInteractorInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 27/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

protocol CameraInteractorDelegate {
    func trackVideoRecorded(videoLenght:Double)
    func flashOn()
    func flashOff()
    func cameraFront()
    func cameraRear()
}

protocol CameraInteractorInterface {
    init(display:GPUImageView, cameraDelegate: CameraInteractorDelegate)
    func setResolution()
    func getClipsArray() -> [String]
    func setIsRecording(isRecording:Bool)
    func startRecordVideo(completion:(String)->Void)
    func rotateCamera()
    func cameraViewTapAction(tapDisplay:UIGestureRecognizer)
    func zoom(pinch: UIPinchGestureRecognizer)
    func resetClipsArray()
    
    func changeBlendImage(image:UIImage)
    func changeFilter(newFilter:GPUImageFilter)
    func removeFilters()
    func removeOverlay()
    func removeShaders()
}

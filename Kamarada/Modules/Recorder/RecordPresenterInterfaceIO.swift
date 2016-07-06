//
//  RecordPresenterInterfaceIO.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

protocol RecordPresenterInput{
    
}

protocol RecordPresenterDelegate{
    func setProgressToSeekBar(progressTime:Float)

}

protocol RecordPresenterInterface{
    func viewDidLoad(displayView:GPUImageView)
    func viewWillDisappear()
    func viewWillAppear()
    func pushSettings()
    func pushShare()
    func pushFlash()
    func pushRecord()
    func pushSepiaFilter()
    func pushBlueFilter()
    func pushBWFilter()
    func pushRotateCamera()
    func pushChangeMusic()
    func resetRecorder()
//    func displayHasTapped(tapGesture:UIGestureRecognizer)
//    func displayHasPinched(pinchGesture:UIPinchGestureRecognizer)
}
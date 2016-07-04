//
//  CameraRecorderInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 30/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

protocol CameraRecorderInterface {
    
}
protocol CameraRecorderDelegate {
    func startRecordVideo(completion:(String)->Void)
    func stopRecordVideo()
}
//
//  RecordViewInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

protocol RecordViewInterface {
    
    func showRecordButton()
    
    func showStopButton()
    
    func recordButtonEnable(state:Bool)
    
    func showSettings()
    
    func hideSettings()
    
    func showRecordedVideoThumb(imageView:UIImageView)

    func showNumberVideos(nClips:Int)

    func hideRecordedVideoThumb()
    
    func showFlashOn(on:Bool)
    
    func showFlashSupported(state:Bool)
    
    func showFrontCameraSelected()
    
    func showBackCameraSelected()
    
    func enableShareButton()
    
    func disableShareButton()
    
    func selectSepiaButton()
    
    func unselectSepiaButton()
    
    func selectBlueButton()
    
    func unselectBlueButton()
    
    func selectBWButton()
    
    func unselectBWButton()
    
    func createAlertWaitToExport()
    
    func dissmissAlertWaitToExport(completion:()->Void)
    
    func resetView()
    
    func getThumbnailSize()->CGFloat
    
    func setSongImage(image:UIImage)

}
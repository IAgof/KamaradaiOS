//
//  AddFilterInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 25/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

class AddFilterInteractor{
    func addFilter(actualFilter:GPUImageFilter, newFilter:GPUImageFilter,display:GPUImageView){
        newFilter.removeAllTargets()
        actualFilter.removeAllTargets()
        actualFilter.addTarget(newFilter)
        
        newFilter.addTarget(display)
    }
    func addBlendFilter(actualFilter:GPUImageFilter, blendFilter: GPUImageAlphaBlendFilter ,blendImage: UIImage, display: GPUImageView){
        blendFilter.removeAllTargets()
        actualFilter.removeAllTargets()
        
        let sourceImage = GPUImagePicture.init(image: blendImage)
        sourceImage.forceProcessingAtSize(display.sizeInPixels)
        
        blendFilter.mix = 1.0
        
        actualFilter.addTarget(blendFilter)
        sourceImage.addTarget(blendFilter)
        sourceImage.processImage()
        
        blendFilter.addTarget(display)
        
        blendFilter.useNextFrameForImageCapture()

    }
}
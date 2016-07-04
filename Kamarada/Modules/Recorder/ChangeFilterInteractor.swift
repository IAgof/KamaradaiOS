//
//  ChangeFilterInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 25/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import GPUImage

class ChangeFilterInteractor{
    func changeFilter(baseFilter:GPUImageFilter, newFilter:GPUImageFilter,display:GPUImageView){
        newFilter.removeAllTargets()
        baseFilter.removeAllTargets()
        baseFilter.addTarget(newFilter)
        
        newFilter.addTarget(display)
    }
}
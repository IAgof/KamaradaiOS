//
//  ShareInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

protocol ShareInterface {
    
    func createShareInterface()
    func setTitleList(titleList: Array<String>)
    func setImageList(imageList: Array<UIImage>)
    func setImagePressedList(imageList: Array<UIImage>)
    func bringToFrontExpandPlayerButton()
    }
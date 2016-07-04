//
//  ShareInteractorInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

protocol ShareInteractorInterface {
    func findSocialNetworks()->(socialNetworkTitleArray:Array<String>, socialNetworkImageArray:Array<UIImage>,socialNetworkImagePressedArray:Array<UIImage>)
    func shareVideo(socialNetworkTitle:String, videoPath:String)
    func setShareMoviePath(moviePath:String)
    func postToYoutube(token:String)
}
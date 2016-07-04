//
//  SharePresenterInterface.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

protocol SharePresenterInterface {
    
    func viewDidLoad()
    func pushBack()
    func setVideoExportedPath(path:String)
    func setNumberOfClipsToExport(numberOfClips:Int)
    func pushShare(socialNetwork:String)
    func postToYoutube(token:String)
    func goToSettings()
    func pushShareButton()
}
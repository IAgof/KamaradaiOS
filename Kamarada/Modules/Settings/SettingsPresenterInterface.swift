//
//  SettingsPresenterInterface.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

protocol SettingsPresenterInterface {
    
    func pushBack()
    func viewDidLoad()
    func itemListSelected(itemTitle:String)
    func getInputFromAlert(settingsTitle:String,input:String)
}
//
//  SettingsInteractorInterface.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

protocol SettingsInteractorInterface {
    func findSettings()->(Array<String>,Array<Array<Array<String>>>)
}
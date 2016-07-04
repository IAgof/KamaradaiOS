//
//  DetailTextInteractor.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 9/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class DetailTextInteractor: NSObject ,DetailTextInteractorInterface{
    
    func getTextFromInternalMemory(key:String) -> String {
        return NSBundle.mainBundle().localizedStringForKey(key,value: "",table: "Settings")
    }
}
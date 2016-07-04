//
//  SettingsInteractor.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SettingsInteractor: NSObject,SettingsInteractorInterface {
    var orderArray = Dictionary<Int,String>()
    var presenter: SettingsPresenterInterface?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var settingSelected:SettingsContent?
    
    func findSettings()->(Array<String>,Array<Array<Array<String>>>){
        
        let settings = SettingsProvider().getSettings()
        
        let settingsContent = self.setSettingsContent(settings)
        
        return settingsContent
    }
    
    func setSettingsContent(settingsContentObjectArray:Array<SettingsContent>)->(Array<String>,Array<Array<Array<String>>>){
        
        var settingsDictionary = Dictionary<String,Array<Array<String>>>()
        
        //Get the order of the arrays by one Dictionary to set up later.
        orderArray = self.getOrderDictionaryByPriority(settingsContentObjectArray)
        
        var title = Array<String>()
        var subTitles = Array<String>()
        
        var compArrayTitleAndSubtitle = Array<Array<String>>()
        
        for settingsItem in settingsContentObjectArray{
            let section = settingsItem.getSection()
            
            if settingsDictionary.indexForKey(section) == nil{//First insertion
                title = Array<String>()
                title.append(settingsItem.getSettingsTitle())
                
                subTitles = Array<String>()
                subTitles.append(settingsItem.getSettingsSubtitle())
                
                compArrayTitleAndSubtitle = Array<Array<String>>()
                compArrayTitleAndSubtitle.append(title)
                compArrayTitleAndSubtitle.append(subTitles)
                
                settingsDictionary[section] = compArrayTitleAndSubtitle
                
            }else{//add objects to different sections
                var auxArray = settingsDictionary[section]
                
                auxArray?[0].append(settingsItem.getSettingsTitle())
                auxArray?[1].append(settingsItem.getSettingsSubtitle())
                
                settingsDictionary[section] = auxArray
            }
        }
        
        //        print("setSettingsContent: -\n \(settingsDictionary)")
        
        let returnSectionsAndTitles = self.setSectionsAndTitles(settingsDictionary)
        
        
        return returnSectionsAndTitles
    }
    
    func setSectionsAndTitles(dictionary: Dictionary<String,Array<Array<String>>>)->(Array<String>,Array<Array<Array<String>>>){
        var sections = Array<String>()
        var titles = Array<Array<Array<String>>>()
        
        
        for var i = 0; i <= orderArray.count; i += 1 {
            if let key = orderArray[i]{
                if let titleArray = dictionary[key]{
                    sections.append(key)
                    titles.append(titleArray)
                }
            }
        }
        //        print("setSections: -\n \(sections)")
        return (sections,titles)
    }
    
    func getOrderDictionaryByPriority(settingsContent:Array<SettingsContent>)->Dictionary<Int,String>{
        var orderByKey = Dictionary<Int,String>()
        
        var prevSection = ""
        for setting in settingsContent{
            let actualSection = setting.getSection()
            if actualSection != prevSection{
                prevSection = actualSection
                orderByKey[setting.getPriority()] = actualSection
            }
        }
        
        //        print("getOrderDictionaryByPriority\n \(orderByKey)")
        return orderByKey
    }
    
    func saveNameOnDefaults(name:String){ // Save name on internal memory
        defaults.setObject(name, forKey: SettingsConstants().SETTINGS_NAME)
    }
    
    func saveUserNameOnDefaults(userName:String){ // Save name on internal memory
        defaults.setObject(userName, forKey: SettingsConstants().SETTINGS_USERNAME)
    }
    
    func saveEmailOnDefaults(email:String){ // Save name on internal memory
        defaults.setObject(email, forKey: SettingsConstants().SETTINGS_MAIL)
    }
    
    func saveResolutionOnDefaults(resolution:String){ // Save name on internal memory
        let resolutionToSave = AVResolutionParse().parseResolutionsToInteractor(resolution)
        
        defaults.setObject(resolutionToSave, forKey: SettingsConstants().SETTINGS_RESOLUTION)
    }
    
    func saveQualityOnDefaults(quality:String){ // Save name on internal memory
        defaults.setObject(quality, forKey: SettingsConstants().SETTINGS_QUALITY)
    }
    
    func isValidEmail(email:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    //MARK: - AVResolution posible inputs
    func getAVResolutions()->Array<String>{
        let resolutions = AVResolutionParse().resolutionsToView()
        
        return resolutions
    }
    
    //MARK: - AVQuality posible inputs
    func getAVQualitys()->Array<String>{
//        let qualitys = AVQualityParse().qualityToView()
        
        return Array<String>()
    }
    
    func setSettingSelected() {
        self.settingSelected = nil
    }
}
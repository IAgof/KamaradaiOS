//
//  SettingsProvider.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import AVFoundation

class SettingsProvider:NSObject{
    
    struct userInfo {
        var name:String
        var userName:String
        var email:String
        init(){
            let defaults = NSUserDefaults.standardUserDefaults()
            
            let nameSaved = defaults.stringForKey(SettingsConstants().SETTINGS_NAME)
            if (nameSaved != nil){
                name = nameSaved!
            }else{
                name = ""
            }
            
            let userNameSaved = defaults.stringForKey(SettingsConstants().SETTINGS_USERNAME)
            if (userNameSaved != nil){
                userName = userNameSaved!
            }else{
                userName = ""
            }
            
            let emailSaved = defaults.stringForKey(SettingsConstants().SETTINGS_MAIL)
            if (emailSaved != nil){
                email = emailSaved!
            }else{
                email = ""
            }
        }
    }
    
    struct cameraSettings {
        var resolution:String
        var quality:String
        
        init(){
            let defaults = NSUserDefaults.standardUserDefaults()
            
            let resolutionSaved = defaults.stringForKey(SettingsConstants().SETTINGS_RESOLUTION)
            
            if (resolutionSaved != nil){
                resolution = AVResolutionParse().parseResolutionToView(resolutionSaved!)
                
            }else{
                resolution = AVResolutionParse().parseResolutionToView(AVCaptureSessionPreset1280x720)
            }
            
            let qualitySaved = defaults.stringForKey(SettingsConstants().SETTINGS_QUALITY)
            if (qualitySaved != nil){
                quality = qualitySaved!
            }else{
                quality = ""
            }
        }
    }
    func getSettings() ->Array<SettingsContent>{
        var settings = Array<SettingsContent>()
        
        //MARK: - ADVANCED_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().VISIT_VIDEONA)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ADVANCED_SECTION)
            ,priority: 0))
        
        //MARK: - MORE_INFO_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().ABOUT_US_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().ABOUT_US_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 1))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().PRIVACY_POLICY_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().PRIVACY_POLICY_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 1))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().TERMS_OF_SERVICE_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().TERMS_OF_SERVICE_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 1))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().LICENSES_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().LICENSES_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 1))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().LEGAL_ADVICE_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().LEGAL_ADVICE_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 1))
        
        //MARK: - ACCOUNT_ACTIONS_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().EXIT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ACCOUNT_ACTIONS_SECTION)
            ,priority: 2))
        
        return settings
    }
    
    
    func getStringForType(type:SettingsType)->String{

        switch type {
        case .VisitVideona:
            return Utils().getStringByKeyFromSettings(SettingsConstants().VISIT_VIDEONA)
        case .AboutUs:
            return Utils().getStringByKeyFromSettings(SettingsConstants().ABOUT_US_TITLE)
        case .PrivacyPolicy:
            return Utils().getStringByKeyFromSettings(SettingsConstants().PRIVACY_POLICY_TITLE)
        case .TermsOfService:
            return Utils().getStringByKeyFromSettings(SettingsConstants().TERMS_OF_SERVICE_TITLE)
        case .Licenses:
            return Utils().getStringByKeyFromSettings(SettingsConstants().LICENSES_TITLE)
        case .LegalAdvice:
            return Utils().getStringByKeyFromSettings(SettingsConstants().LEGAL_ADVICE_TITLE)
        case .Exit:
            return Utils().getStringByKeyFromSettings(SettingsConstants().EXIT)
        }
    }
}

enum SettingsType {
    case VisitVideona
    
    case AboutUs
    case PrivacyPolicy
    case TermsOfService
    case Licenses
    case LegalAdvice
    
    case Exit
}
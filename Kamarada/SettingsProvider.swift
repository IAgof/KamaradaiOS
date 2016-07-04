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
        let user = userInfo()
        let camera = cameraSettings()
        
        //MARK: - ADVANCED_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().DONWLOAD_KAMARADA)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ADVANCED_SECTION)
            ,priority: 0))
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().SHARE_VIDEONA_TITLE)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ADVANCED_SECTION)
            ,priority: 0))
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().FOLLOW_US_ON_TWITTER_TITLE)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ADVANCED_SECTION)
            ,priority: 0))
        
        //MARK: - MY_ACCOUNT_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().NAME)
            ,subTitle: user.name
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MY_ACCOUNT_SECTION)
            ,priority: 1))
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().USER_NAME)
            ,subTitle: user.userName
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MY_ACCOUNT_SECTION)
            ,priority: 1))
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().EMAIL_PREFERENCE)
            ,subTitle: user.email
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MY_ACCOUNT_SECTION)
            ,priority: 1))
        
        //MARK: - CAMERA_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().RESOLUTION)
            ,subTitle: camera.resolution
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().CAMERA_SECTION)
            ,priority: 2))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().QUALITY)
            ,subTitle: camera.quality
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().CAMERA_SECTION)
            ,priority: 2))
        
        //MARK: - MORE_INFO_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().ABOUT_US_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().ABOUT_US_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 3))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().PRIVACY_POLICY_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().PRIVACY_POLICY_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 3))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().TERMS_OF_SERVICE_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().TERMS_OF_SERVICE_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 3))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().LICENSES_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().LICENSES_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 3))
        
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().LEGAL_ADVICE_TITLE)
            ,content: Utils().getStringByKeyFromSettings(SettingsConstants().LEGAL_ADVICE_CONTENT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().MORE_INFO_SECTION)
            ,priority: 3))
        
        //MARK: - ACCOUNT_ACTIONS_SECTION
        settings.append( SettingsContent(title: Utils().getStringByKeyFromSettings(SettingsConstants().EXIT)
            ,section: Utils().getStringByKeyFromSettings(SettingsConstants().ACCOUNT_ACTIONS_SECTION)
            ,priority: 4))
        
        return settings
    }
    
    
    func getStringForType(type:SettingsType)->String{
        switch type {
        case .DownloadKamarada:
            return Utils().getStringByKeyFromSettings(SettingsConstants().DONWLOAD_KAMARADA)
        case .ShareVideona:
            return Utils().getStringByKeyFromSettings(SettingsConstants().SHARE_VIDEONA_TITLE)
        case .FollowUsOnTwitter:
            return Utils().getStringByKeyFromSettings(SettingsConstants().FOLLOW_US_ON_TWITTER_TITLE)
        case .NameAccount:
            return Utils().getStringByKeyFromSettings(SettingsConstants().NAME)
        case .UserNameAccount:
            return Utils().getStringByKeyFromSettings(SettingsConstants().USER_NAME)
        case .emailAccount:
            return Utils().getStringByKeyFromSettings(SettingsConstants().EMAIL_PREFERENCE)
        case .Resolution:
            return Utils().getStringByKeyFromSettings(SettingsConstants().RESOLUTION)
        case .Quality:
            return Utils().getStringByKeyFromSettings(SettingsConstants().QUALITY)
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
    case DownloadKamarada
    case ShareVideona
    case FollowUsOnTwitter
    
    case NameAccount
    case UserNameAccount
    case emailAccount
    
    case Resolution
    case Quality
    
    case AboutUs
    case PrivacyPolicy
    case TermsOfService
    case Licenses
    case LegalAdvice
    
    case Exit
}
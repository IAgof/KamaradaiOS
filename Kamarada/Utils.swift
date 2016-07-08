//
//  Utils.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 21/4/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class Utils{
    let udid = UIDevice.currentDevice().identifierForVendor!.UUIDString
    let defaults = NSUserDefaults.standardUserDefaults()

    func getDoubleHourAndMinutes() -> Double{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        let hour = components.hour
        let minutes = components.minute

        return Double(hour) + (Double(minutes))/60;
    }
    
    func giveMeTimeNow()->String{
        var dateString:String = ""
        let dateFormatter = NSDateFormatter()
        
        let date = NSDate()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "es_ES")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 3600) //GMT +1
        dateString = dateFormatter.stringFromDate(date)
        
        Utils().debugLog("La hora es : \(dateString)")
        
        return dateString
    }
    
    func debugLog(logMessage:String){
        #if DEBUG
            print("\n \(logMessage)")
        #endif
    }
    
    func getUDID() -> String{
        return udid
    }
    
    func getStringByKeyFromSettings(key:String) -> String {
        return NSBundle.mainBundle().localizedStringForKey(key,value: "",table: "Settings")
    }
    
    func getStringByKeyFromShare(key:String) -> String {
        return NSBundle.mainBundle().localizedStringForKey(key,value: "",table: "Share")
    }
    
    func getStringByKeyFromIntro(key:String) -> String {
        return NSBundle.mainBundle().localizedStringForKey(key,value: "",table: "Intro")
    }
    
    func saveToPreferences(value:AnyObject, key:String){
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
    
    func getValueFromPreferences(key:String)->String{
        let objectSaved = defaults.stringForKey(key)
        
        var object = ""
        
        if (objectSaved != nil){
            object = objectSaved!
            
        }else{
            object = "kamarada_audio"
        }
        
        return object
    }
}
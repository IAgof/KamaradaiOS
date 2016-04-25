//
//  AppDelegate.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 28/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var mixpanel:Mixpanel?
    var initState = "firstTime"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        print("START Kamarada")
        //Google Sign in
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        //MIXPANEL
        Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
        mixpanel = Mixpanel.sharedInstance()
        mixpanel!.timeEvent(AnalyticsConstants().TIME_IN_ACTIVITY)
        
        //Init MixPanel
        dispatch_async(dispatch_get_main_queue()) {
            self.setupStartApp()
            self.trackUserProfileGeneralTraits()
            self.sendStartupAppTracking()
        }
        
        //FaceBook SDK
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("\nEnter in applicationWillResignActive\n")

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\nEnter in applicationDidEnterBackground\n")
        self.sendTimeInActivity(application)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject?) -> Bool {
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,
                                            UIApplicationOpenURLOptionsAnnotationKey: annotation!]
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)

    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            print("userID: \(userId) \n idToken: \(idToken) \n fullName: \(fullName) \n givenName: \(givenName) \n familyName: \(familyName) \n email: \(email) \n")
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // MIXPANEL
    func sendTimeInActivity(application: UIApplication){
        print("Sending AnalyticsConstants().TIME_IN_ACTIVITY")
        //NOT WORKING -- falta el comienzo time_event para arrancar el contador
        
        let navigationController = application.windows[0].rootViewController as! UINavigationController
        let whatClass = String(object_getClass(navigationController.topViewController))
        print("what class is \(whatClass)")
        
        let viewProperties = [AnalyticsConstants().ACTIVITY:whatClass]
        mixpanel!.track(AnalyticsConstants().TIME_IN_ACTIVITY, properties: viewProperties)
        mixpanel!.flush()
    }
    
    func sendStartupAppTracking() {
        let initAppProperties = [AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_ORGANIC,
                                 AnalyticsConstants().INIT_STATE:initState,
                                 AnalyticsConstants().DOUBLE_HOUR_AND_MINUTES: Utils().getDoubleHourAndMinutes()]
        mixpanel?.track(AnalyticsConstants().APP_STARTED, properties: initAppProperties as [NSObject : AnyObject])
    }
    
    func setupStartApp() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let currentAppVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let previousVersion = defaults.stringForKey("appVersion")
        if previousVersion == nil {
            // first launch
            defaults.setObject(currentAppVersion, forKey: "appVersion")
            defaults.synchronize()
            
            print("First time")
            initState = "firstTime"
            
            trackUserProfile();
            trackCreatedSuperProperty();
            trackAppStartupProperties(true);
            
        } else if previousVersion == currentAppVersion {
            // same version
            print("Same version")
            initState = "returning"
            
            trackAppStartupProperties(false);
            
        } else {
            // other version
            defaults.setObject(currentAppVersion, forKey: "appVersion")
            defaults.synchronize()
            
            print("Update to \(currentAppVersion)")
            initState = "upgrade"
            
            trackUserProfile();
            trackAppStartupProperties(false);
        }
    }
    
    
    func trackAppStartupProperties(state:Bool) {
        var appUseCount:Int
        let properties = mixpanel!.currentSuperProperties()
        if let count = properties[AnalyticsConstants().APP_USE_COUNT]{
            appUseCount = count as! Int
        }else{
            appUseCount = 0
        }
        appUseCount += 1

        let appStartupSuperProperties = [AnalyticsConstants().APP_USE_COUNT:appUseCount,
                                 AnalyticsConstants().FIRST_TIME:state,
                                 AnalyticsConstants().APP: "Kamarada"]
        mixpanel?.registerSuperProperties(appStartupSuperProperties as [NSObject : AnyObject])
    }
    func trackUserProfile() {
        let udid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        print("The user id is = \(udid)")
        mixpanel!.identify(udid)
        //        mixpanel.getPeople().identify(androidId);
        let userProfileProperties = [AnalyticsConstants().CREATED:Utils().giveMeTimeNow()]
        mixpanel?.people.setOnce(userProfileProperties)
    }
    
    func trackUserProfileGeneralTraits() {
        mixpanel?.people.increment(AnalyticsConstants().APP_USE_COUNT,by: 1)

        let locale = NSLocale.preferredLanguages()[0]
        let lang = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)
        
        let userProfileProperties = [AnalyticsConstants().TYPE:AnalyticsConstants().TYPE_PAID,
                                         AnalyticsConstants().LOCALE:locale,
                                         AnalyticsConstants().LANG: lang!] as [NSObject : AnyObject]
        
        mixpanel?.people.set(userProfileProperties)
    }
    
    func trackCreatedSuperProperty() {
        let createdSuperProperty = [AnalyticsConstants().CREATED: Utils().giveMeTimeNow()]
        mixpanel?.registerSuperPropertiesOnce(createdSuperProperty)
    }
}


//
//  AnalitycsConstants.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 21/4/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation


class AnalyticsConstants {
    
    /**
     * Token
     */
    #if DEBUG
    let MIXPANEL_TOKEN = "c6617213110cd2513dfc0ad97dbaee66"
    #else
    let MIXPANEL_TOKEN = "bb9e99661ccafc2a391dc292aa007e75"
    #endif
    
    /**
     * Events
     */
    let APP_STARTED = "App Started"
    let VIDEO_RECORDED = "Video Recorded"
    let VIDEO_EXPORTED = "Video Exported"
    let VIDEO_SHARED = "Video Shared"
    let USER_INTERACTED = "User Interacted"
    let FILTER_SELECTED = "Filter Selected"
    let TIME_IN_ACTIVITY = "Time in Activity"
    
    /**
     * Values
     */
    let TYPE = "type"
    let TYPE_PAID = "paid"
    let TYPE_ORGANIC = "organic"
    let TYPE_COLOR = "color"
    let CREATED = "created"
    let LOCALE = "locale"
    let LANG = "lang"
    let INIT_STATE = "initState"
    let ACTIVITY = "activity"
    let RECORDING = "recording"
    let INTERACTION = "interaction"
    let INTERACTION_OPEN_SETTINGS = "settings opened"
    let RESULT = "result"
    let VIDEO_LENGTH = "videoLength"
    let RESOLUTION = "resolution"
    let QUALITY = "quality"
    let NUMBER_OF_CLIPS = "numberOfClips"
    let NAME = "name"
    let TOTAL_VIDEOS_RECORDED = "totalVideosRecorded"
    let LAST_VIDEO_RECORDED = "lastVideoRecorded"
    let CODE = "code"
    let FILTER_NAME_SEPIA = "sepia"
    let FILTER_NAME_MONO = "mono"
    let FILTER_NAME_AQUA = "aqua"
    let FILTER_CODE_SEPIA = "ad8"
    let FILTER_CODE_MONO = "ad4"
    let FILTER_CODE_AQUA = "ad1"
    let CHANGE_SKIN = "change skin"
    let CHANGE_FLASH = "change flash"
    let SKIN_WOOD = "wood"
    let SKIN_LEATHER = "leather"
    let RECORD = "record"
    let START = "start"
    let STOP = "stop"
    let CHANGE_CAMERA = "change camera"
    let TOTAL_VIDEOS_SHARED = "totalVideosShared"
    let SOCIAL_NETWORK = "socialNetwork"
    let LAST_VIDEO_SHARED = "lastVideoShared"
    let SWIPE = "swipe"
    let LEFT = "left"
    let RIGHT = "right"
    let FIRST_TIME = "firstTime"
    let APP_USE_COUNT = "appUseCount"
    let APP = "app"
    let DOUBLE_HOUR_AND_MINUTES = "doubleHourAndMinutes"
    let WHATSAPP = "Whatsapp"
    let INSTAGRAM = "Instagram"
    let FACEBOOK = "Facebook"
    let YOUTUBE = "Youtube"
}


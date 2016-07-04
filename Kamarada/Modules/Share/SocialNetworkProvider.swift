//
//  SocialNetworkProvider.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 13/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class SocialNetworkProvider:NSObject{
    
    func getSocialNetworks() ->Array<SocialNetwork>{
        var socialNetworks = Array<SocialNetwork>()
        
        socialNetworks.append( SocialNetwork(iconId: "share_icon_facebook_normal",
            iconIdPressed: "share_icon_facebook_pressed",
            title: "Facebook"))
        socialNetworks.append( SocialNetwork(iconId: "share_icon_instagram_normal",
            iconIdPressed: "share_icon_instagram_pressed",
            title: "Instagram"))
        socialNetworks.append(SocialNetwork(iconId: "share_icon_twitter_norma",
            iconIdPressed: "share_icon_twitter_pressed",
            title: "Twitter"))
        socialNetworks.append(SocialNetwork(iconId: "share_icon_whatsapp_normal",
            iconIdPressed: "share_icon_whatsapp_pressed",
            title: "Whatsapp"))
        socialNetworks.append(SocialNetwork(iconId: "share_icon_youtube_norma",
            iconIdPressed: "share_icon_youtube_pressed",
            title: "Youtube"))
        
        return socialNetworks
    }
}
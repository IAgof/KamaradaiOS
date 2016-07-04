//
//  SharePresenter.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 11/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SharePresenter:NSObject,SharePresenterInterface{
    
    var wireframe: ShareWireframe?
    var controller: ShareViewController?
    var interactor: ShareInteractor?
    var recordWireframe: RecordWireframe?
    
    var videoPath = ""
    var numberOfClips = 0
    
    //LifeCicle
    func viewDidLoad() {
        controller!.createShareInterface()
        controller?.setNavBarTitle(Utils().getStringByKeyFromSettings(SettingsConstants().SHARE_VIDEONA_TITLE))
                
        self.getListData()
        
        controller?.bringToFrontExpandPlayerButton()
    }
    
    func setVideoExportedPath(path: String) {
        self.videoPath = path
        
    }
    
    func setNumberOfClipsToExport(numberOfClips: Int) {
        self.numberOfClips = numberOfClips
    }
    
    func pushBack() {
        wireframe?.goPrevController()
    }
    
    func getListData (){
       let socialNetworks = interactor?.findSocialNetworks()
        
        self.setListImageData((socialNetworks?.socialNetworkImageArray)!)
        self.setListTitleData((socialNetworks?.socialNetworkTitleArray)!)
        self.setListImagePressedData((socialNetworks?.socialNetworkImagePressedArray)!)
    }
    
    func setListTitleData(titleArray:Array<String>){
        controller?.setTitleList(titleArray)
    }
    
    func setListImageData(imageArray:Array<UIImage>){
        controller?.setImageList(imageArray)
    }
    
    func setListImagePressedData(imageArray:Array<UIImage>){
        controller?.setImagePressedList(imageArray)
    }
    func pushShare(socialNetwork: String) {
        interactor?.shareVideo(socialNetwork, videoPath: videoPath)
        
        trackVideoShared(socialNetwork)
    }
    
    func postToYoutube(token:String){
        interactor!.postToYoutube(token)
    }
    
    //MARK: - Mixpanel Tracking
    func trackVideoShared(socialNetworkName: String) {
        let duration = AVAsset(URL: NSURL(fileURLWithPath: videoPath)).duration.seconds
        
        controller?.getTrackerObject().trackVideoShared(socialNetworkName,
                                                        videoDuration: duration,
                                                        numberOfClips: numberOfClips)
    }
}
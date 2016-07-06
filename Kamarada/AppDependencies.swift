//
//  AppDependencies.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 3/5/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

class AppDependencies {
    
    var recordWireframe = RecordWireframe()
    var settingsWireframe = SettingsWireframe()
    var shareWireframe = ShareWireframe()
    var playerWireframe = PlayerWireframe()
    var detailTextWireframe = DetailTextWireframe()
    var musicListWireframe = MusicListWireframe()
    
    init(){
        configureDependencies()
    }
    func configureDependencies(){
        let rootWireframe = RootWireframe()
        let recordPresenter = RecordPresenter()
        let settingsPresenter = SettingsPresenter()
        let settingsInteractor = SettingsInteractor()
        
        let sharePresenter = SharePresenter()
        let shareInteractor = ShareInteractor()
       
        let playerPresenter = PlayerPresenter()
        let playerInteractor = PlayerInteractor()
        
        let detailTextPresenter = DetailTextPresenter()
        let detailTextInteractor = DetailTextInteractor()

        let musicListPresenter = MusicListPresenter()
        let musicListInteractor = MusicListInteractor()
        
        //RECORD MODULE
        recordPresenter.recordWireframe = recordWireframe
        recordPresenter.settingsWireframe = settingsWireframe
        recordPresenter.shareWireframe = shareWireframe
        recordPresenter.musicWireframe = musicListWireframe
        
        recordWireframe.recordPresenter = recordPresenter
        recordWireframe.rootWireframe = rootWireframe
        
        //SETTINGS MODULE
        settingsPresenter.wireframe = settingsWireframe
        settingsPresenter.recordWireframe = recordWireframe
        settingsPresenter.interactor = settingsInteractor
        settingsPresenter.detailTextWireframe = detailTextWireframe
        
        settingsWireframe.settingsPresenter = settingsPresenter
        settingsWireframe.rootWireframe = rootWireframe
        
        settingsInteractor.presenter = settingsPresenter
        
        //SHARE MODULE
        sharePresenter.wireframe = shareWireframe
        sharePresenter.interactor = shareInteractor
        sharePresenter.playerPresenter = playerPresenter
        
        shareWireframe.sharePresenter = sharePresenter
        shareWireframe.rootWireframe = rootWireframe
        shareWireframe.playerWireframe = playerWireframe
        shareWireframe.settingsWireframe = settingsWireframe
        
        //PLAYER MODULE
        playerPresenter.wireframe = playerWireframe
        playerPresenter.recordWireframe = recordWireframe
        playerPresenter.playerInteractor = playerInteractor

        playerWireframe.playerPresenter = playerPresenter
        playerWireframe.rootWireframe = rootWireframe
       
        //DETAIL TEXT MODULE
        detailTextPresenter.wireframe = detailTextWireframe
        detailTextPresenter.interactor = detailTextInteractor
        
        detailTextWireframe.detailTextPresenter = detailTextPresenter
        detailTextWireframe.rootWireframe = rootWireframe

        //MUSIC LIST MODULE
        musicListPresenter.wireframe = musicListWireframe
        musicListPresenter.interactor = musicListInteractor
        
        musicListInteractor.presenter = musicListPresenter
        musicListInteractor.delegate = musicListPresenter
        
        musicListWireframe.musicListPresenter = musicListPresenter
        musicListWireframe.rootWireframe = rootWireframe
    }
    
    func installRecordToRootViewControllerIntoWindow(window: UIWindow){
        recordWireframe.presentRecordInterfaceFromWindow(window)
    }
    
    func installMusicListToRootViewControllerIntoWindow(window: UIWindow){
        musicListWireframe.presentMusicInterfaceFromWindow(window)
    }
}
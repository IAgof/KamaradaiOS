//
//  SettingsInterface.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

protocol SettingsInterface {
    
    
    func setListTitleAndSubtitleData(titleList: Array<Array<Array<String>>>)
    func setSectionList(section: Array<String>)
    func registerClass()
    func reloadTableData()
    func createAlertExit()
    func setNavBarTitle(title:String)
    func createActiviyVCShareVideona(text:String)
}
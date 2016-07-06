//
//  SettingsViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 29/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: KamaradaController,
    SettingsInterface ,
UINavigationBarDelegate,
UITableViewDelegate,UITableViewDataSource{
    
    var eventHandler: SettingsPresenterInterface?
    var titleBar = "Share video"
    var titleBackButtonBar = "Back"
    
    let reuseIdentifierCell = "settingsCell"
    
    //MARK: - List variables
    var section = Array<String>()
    var items = Array<Array<Array<String>>>()
    
    //MARK: - Outlets
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingsNavBar: UINavigationItem!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        eventHandler?.viewDidLoad()
    }
    
    //MARK: - init view
    func registerClass(){
        settingsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierCell)
    }
    
    func setNavBarTitle(title:String){
        settingsNavBar.title = title
    }
    
    @IBAction func pushBackBarButton(sender: AnyObject) {
        eventHandler?.pushBack()
    }
    
    func setListTitleAndSubtitleData(titleAndSubtitleList: Array<Array<Array<String>>>) {
        self.items = titleAndSubtitleList
    }
    
    func setSectionList(section: Array<String>) {
        self.section = section
    }
    
    func addFooter() {
        
        let footer = UINib(nibName: "VideonaFooterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
        
        let footerTest = UIView.init(frame: footer.frame)
        footerTest.addSubview(footer)
        
        settingsTableView.tableFooterView = footerTest
        
    }
    
    //MARK: - UITableview datasource
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        //        return self.section.count
        return section.count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.items[section][0].count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? =
            tableView.dequeueReusableCellWithIdentifier(reuseIdentifierCell)
        if (cell != nil)
        {
            cell = UITableViewCell(style: .Value1,
                                   reuseIdentifier: reuseIdentifierCell)
        }
        // Configure the cell...
        
        let title = self.items[indexPath.section][0][indexPath.row]
        let subTitle = self.items[indexPath.section][1][indexPath.row]
        
        cell!.textLabel?.text = title
        
        if subTitle != ""{
            cell!.detailTextLabel?.text = self.items[indexPath.section][1][indexPath.row]
            print("\n Title equals = \(title) \n Subtitle equals = \(subTitle)")
        }
        cell!.detailTextLabel?.adjustsFontSizeToFitWidth
        cell!.textLabel?.adjustsFontSizeToFitWidth
        
        return cell!
    }
    
    //MARK: - UITableview delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //cell push
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let settingsOption = items[indexPath.section][0][indexPath.item]
        print("Settings option #\(indexPath.item)\n option selected: \(settingsOption)!")
        eventHandler?.itemListSelected(settingsOption)
    }
    
    
    //MARK: - AlertViewController
    func createAlertViewError(buttonText:String,message:String,title:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: buttonText, style: .Destructive, handler: nil)
        
        alertController.addAction(saveAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func createAlertExit(){
        
        // create the alert
        let alert = UIAlertController(title: "Exit", message: "Do you want to exit application?", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.Destructive, handler: { action in
            
            // do something like...
            exit(1)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reloadTableData() {
        self.settingsTableView.reloadData()
    }
    
    func createActiviyVCShareVideona(text:String){
        var whatsAppText:String = "whatsapp://send?text="
        whatsAppText.appendContentsOf(text)
        
        let whatsAppTextCoded = whatsAppText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        let whatsappURL = NSURL.init(string: whatsAppTextCoded!)
        
        if UIApplication.sharedApplication().canOpenURL(whatsappURL!){
            UIApplication.sharedApplication().openURL(whatsappURL!)
        }else{
            self.createAlertViewError("OK",
                                      message: Utils().getStringByKeyFromSettings(SettingsConstants().WHATSAPP_NOT_INSTALLED),
                                      title: Utils().getStringByKeyFromSettings(SettingsConstants().SHARE_VIDEONA_TITLE))
        }
    }
}
//
//  SettingsController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 28/3/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Mixpanel

class SettingsController: UITableViewController{
    
    var section = ["title_advanced_section":"", "moreInformation":"", "accountActions":""]
    var items = [["Download Videona"],["aboutUsTitle","privacyPolicy","licenses","termsOfService","legacyAdviceTitle"],
                 ["exit"]]
    var itemsDescription = Array<Array<String>>()
    var contentItems = [["Download Videona"],["aboutUsContent","privacyPolicyContent","licenseContent","termsOfServiceContent","legacyAdviceContent"],
                        ["exit"]]
    var contentItemsDescription = Array<Array<String>>()
    
    #if DEBUG
    var mixpanel = Mixpanel.init(token: AnalyticsConstants().MIXPANEL_TOKEN, andFlushInterval: 2)
    #else
    var mixpanel = Mixpanel.sharedInstanceWithToken(AnalyticsConstants().MIXPANEL_TOKEN)
    #endif
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "activity_settings_background.png"))
        
        self.startTimeInActivityEvent()

        fillArrays()
        animateTable()
        
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.sendTimeInActivity()
    }
    
    //Get from Settings.strings the correct Strings to fill de tableView
    func fillArrays(){
        fillSectionArray()
        fillItemsArray()
        fillContentItemsArray()
    }
    
    func fillSectionArray(){
        for myValue  in section.keys{
            let message = NSBundle.mainBundle().localizedStringForKey(
                myValue,
                value: "",
                table: "Settings")
            
            section[myValue] = message
        }
    }
    
    func fillItemsArray(){
        for i in 0 ..< items.count {
            var newRow = Array<String>()
            for myValue  in items[i]{
                let message = NSBundle.mainBundle().localizedStringForKey(
                    myValue,
                    value: "",
                    table: "Settings")
                
                //                Utils().debugLog("Para la \(myValue) El valor del texto es\n")// \(message)")
                
                newRow.append(message)
            }
            itemsDescription.append(newRow)
        }
    }
    
    func fillContentItemsArray(){
        for i in 0 ..< contentItems.count {
            var newRow = Array<String>()
            for myValue  in contentItems[i]{
                let message = NSBundle.mainBundle().localizedStringForKey(
                    myValue,
                    value: "",
                    table: "Settings")
                
                //                Utils().debugLog("Para la \(myValue) El valor del texto es\n")// \(message)")
                
                newRow.append(message)
            }
            contentItemsDescription.append(newRow)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - Table Animation

    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //get index from integer position on Dictionary
        let index = self.section.startIndex.advancedBy(section)
        
        return self.section.values[index]
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return self.section.count
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.items[section].count
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = self.itemsDescription[indexPath.section][indexPath.row]
        
        return cell
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //Define next screen
                let controller = segue.destinationViewController as! DetailSettingsController
                
                //Set the values to the next screen
                
                let detail = self.contentItemsDescription[indexPath.section][indexPath.row]
                
                controller.detailSettings = detail
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var returned = false
        if identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //Set the values to the next screen
                let detail = self.contentItemsDescription[indexPath.section][indexPath.row]
                
                if(detail=="Download Videona"){
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://videona.com")!)
                    
                    Utils().debugLog("Go to download")
                    
                    //Change the selected background view of the cell.
                    [self.tableView .deselectRowAtIndexPath(indexPath, animated: true)]
                    
                    returned = false
                }else if(detail=="Exit"){
                    self.createAlertExit()
                    
                    //Change the selected background view of the cell.
                    [self.tableView .deselectRowAtIndexPath(indexPath, animated: true)]
                    
                    Utils().debugLog("Exit application")
                    returned = false
                }else{
                    returned = true
                }
            }
        }
        return returned
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
    
    func startTimeInActivityEvent(){
        mixpanel.timeEvent(AnalyticsConstants().TIME_IN_ACTIVITY)
    }
    func sendTimeInActivity() {
        Utils().debugLog("Sending AnalyticsConstants().TIME_IN_ACTIVITY")
        //NOT WORKING -- falta el comienzo time_event para arrancar el contador
        
        let whatClass = String(object_getClass(self))
        Utils().debugLog("what class is \(whatClass)")
        
        let viewProperties = [AnalyticsConstants().ACTIVITY:whatClass]
        mixpanel.track(AnalyticsConstants().TIME_IN_ACTIVITY, properties: viewProperties)
        mixpanel.flush()
    }

}

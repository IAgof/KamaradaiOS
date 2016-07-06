//
//  MusicViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Foundation

class MusicListController: KamaradaController,MusicViewInterface,
UITableViewDataSource,UITableViewDelegate{
    //MARK: - VIPER
    var eventHandler: MusicListPresenterInterface?

    //MARK: - Outlets
    @IBOutlet weak var musicListTableView: UITableView!
    
    //MARK: - Variables 
    let reuseIdentifierCell = "MusicListCell"
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        // Register custom cell
        let nib = UINib(nibName: "MusicListCell", bundle: nil)
        musicListTableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifierCell)
        
    }
    
    //MARK: - Actions
    @IBAction func pushBackButton(sender: AnyObject) {
        eventHandler?.pushBack()
    }
    @IBAction func pushValidationButton(sender: AnyObject) {
   
    }
    
    //MARK: - UITableView data source protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierCell, forIndexPath: indexPath) as! MusicListCell
        cell.playPauseButton.tag = indexPath.row
        cell.playPauseButton.addTarget(self, action: #selector(MusicListController.playPausePushed(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }
    
    func playPausePushed(sender:UIButton) {
        Utils().debugLog("Music controller class \n playPausePushed")

    }
    
    //MARK: - UITableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicListCell
        
        if cell.isSelectedMusic {
            cell.isSelectedMusic = false
        }else{
            cell.isSelectedMusic = true
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        Utils().debugLog("Music controller class \n didDeselectRowAtIndexPath")
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MusicListCell
        cell.isSelectedMusic = false
    }
}

//
//  MusicViewController.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import UIKit
import Foundation

class MusicListController: KamaradaController,MusicViewInterface,MusicPresenterDelegate,
UITableViewDataSource,UITableViewDelegate{
    //MARK: - VIPER
    var eventHandler: MusicListPresenterInterface?

    //MARK: - Outlets
    @IBOutlet weak var musicListTableView: UITableView!
    
    //MARK: - Variables 
    let reuseIdentifierCell = "musicListCell"
    var songsImages : Array<UIImage>!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        
        eventHandler?.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        eventHandler?.viewWillDisappear()
    }
    
    func initVariables() {
        songsImages = Array<UIImage>()
    }
    
    //MARK: - Actions
    @IBAction func pushBackButton(sender: AnyObject) {
        eventHandler?.pushBack()
    }
    @IBAction func pushValidationButton(sender: AnyObject) {
   
    }
    
    //MARK: - UITableView data source protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierCell, forIndexPath: indexPath) as! MusicListCell
        
        cell.coverImageView.image = songsImages[indexPath.row]
        
        cell.playPauseButton.tag = indexPath.row
        
        cell.playPauseButton.addTarget(self, action: "pushPlayPauseButton:", forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }
    
    
    @IBAction func pushPlayPauseButton(sender:UIButton){
        Utils().debugLog("play pause pushed in position \(sender.tag)")
        
        eventHandler?.togglePlayOrPause(sender.tag)
        
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
    
    //MARK: - Presenter delegate
    func setSongsImage(songsImages: Array<UIImage>) {
        self.songsImages = songsImages
    }
    
    func setStateToPlayButton(index: Int, state: Bool) {
        let indexPath =  NSIndexPath(forRow: index, inSection: 0)

        let cell = musicListTableView.cellForRowAtIndexPath(indexPath) as! MusicListCell
        
        cell.playPauseButton.selected = state
        
    }
}

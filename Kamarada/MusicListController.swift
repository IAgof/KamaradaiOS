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
    var songsTranstionImage : Array<UIImage>!
    
    var selectedCellIndexPath:NSIndexPath?
    
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
        eventHandler?.validateSongEvent()
    }
    
    //MARK: - UITableView data source protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierCell, forIndexPath: indexPath) as! MusicListCell
        
        cell.coverImageView.image = songsImages[indexPath.row]
        cell.transitionImageView.image = songsTranstionImage[indexPath.row]
        
        cell.playPauseButton.tag = indexPath.row
        
        cell.playPauseButton.addTarget(self, action: "pushPlayPauseButton:", forControlEvents: UIControlEvents.TouchUpInside)

        if indexPath == selectedCellIndexPath {
            cell.isSelectedMusic = true
            cell.selected = true
        }
        
        return cell
    }
    
    
    @IBAction func pushPlayPauseButton(sender:UIButton){
        Utils().debugLog("play pause pushed in position \(sender.tag)")
        
        eventHandler?.togglePlayOrPause(sender.tag)
        
    }
    
    //MARK: - UITableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        eventHandler?.musicSelectedCell(indexPath.row)
    }
    
    //MARK: - Presenter delegate
    func setSongsImage(songsImages: Array<UIImage>) {
        self.songsImages = songsImages
    }
    
    func setSongsTransitionImage(songsImages: Array<UIImage>) {
        self.songsTranstionImage = songsImages
    }
    func setStateToPlayButton(index: Int, state: Bool) {
        let indexPath =  NSIndexPath(forRow: index, inSection: 0)

        let cell = musicListTableView.cellForRowAtIndexPath(indexPath) as! MusicListCell
        
        cell.playPauseButton.selected = state
        
    }
    
    func setCellIsMusicSelected(index: Int, state: Bool){
        let indexPath =  NSIndexPath(forRow: index, inSection: 0)
        
        if let cell = musicListTableView.cellForRowAtIndexPath(indexPath){
            let cell = cell as! MusicListCell
            cell.isSelectedMusic = state
            cell.selected = state
        }
        

    }
    
    func selectCell(index: Int) {
        self.setCellIsMusicSelected(index, state: true)
    }
    
    func deselectCell(index: Int)  {
        self.setCellIsMusicSelected(index, state: false)
    }
    
    func setselectedCellIndexPath(index:NSIndexPath){
        self.selectedCellIndexPath = index
    }
}

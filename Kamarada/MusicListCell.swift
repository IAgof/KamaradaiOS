//
//  MusicListCell.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 5/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation
import UIKit

class MusicListCell: UITableViewCell {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var transitionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isSelectedMusic = false
        
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clearColor()
    
        let backView = UIView.init(frame: self.frame)
        backView.backgroundColor = UIColor.clearColor()
        self.selectedBackgroundView = backView
        
    }
    
   var isSelectedMusic: Bool {
        didSet {
            Utils().debugLog("Music Cell class \n isSelectedMusic = \(isSelectedMusic)")

            if isSelectedMusic {
                if (coverImageView != nil) {
                    ShowDiscTransition().animateTransition(transitionImageView, completion: nil)
                    self.coverImageView.layer.borderWidth = 3
                    self.coverImageView.layer.borderColor = UIColor.init(red: (253/255), green: (171/255), blue: (83/255), alpha: 1).CGColor
                }
            }else{
                if (coverImageView != nil) {
                    HideDiscTransition().animateTransition(transitionImageView, completion: nil)
                    self.coverImageView.layer.borderColor = UIColor.clearColor().CGColor
                    
                }

            }
        }
    }
    
}

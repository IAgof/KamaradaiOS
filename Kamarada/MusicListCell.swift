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
    @IBOutlet weak var previewImageView: UIImageView!
    
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
                if (previewImageView != nil) {
                    previewImageView.layer.borderWidth = 2
                    previewImageView.layer.borderColor = UIColor.init(red: 0.7411, green: 0.854, blue: 0.074, alpha: 0.8).CGColor
                    self.backgroundColor = UIColor.clearColor()
                    
                }
            }else{
                if (previewImageView != nil) {
                    previewImageView.layer.borderWidth = 0
                    previewImageView.layer.borderColor = UIColor.clearColor().CGColor
                }

            }
        }
    }
    
}

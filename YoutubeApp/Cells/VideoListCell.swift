//
//  VideoListCell.swift
//  YoutubeApp
//
//  Created by Uske on 2020/07/08.
//  Copyright © 2020 Uske. All rights reserved.
//

import UIKit

class VideoListCell: UICollectionViewCell {
    
    @IBOutlet weak var channelImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        channelImageView.layer.cornerRadius = 40 / 2
    }
    
}

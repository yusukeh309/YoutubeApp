//
//  VideoViewController.swift
//  YoutubeApp
//
//  Created by Uske on 2020/08/02.
//  Copyright © 2020 Uske. All rights reserved.
//

import UIKit
import Nuke

class VideoViewController: UIViewController {
    
    var selectedItem: Item?
    private var imageViewCenterY: CGFloat?
    
    var videoImageMaxY: CGFloat {
        let ecludeValue = view.safeAreaInsets.bottom + (imageViewCenterY ?? 0)
        return view.frame.maxY - ecludeValue
    }
    
    var minimumImageViewTrailingConstant: CGFloat {
        -(view.frame.width - (150 + 12))
    }
    
    // videoImageView
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageBackView: UIView!
    
    // backView
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomConstraint: NSLayoutConstraint!
    
    // describeView
    @IBOutlet weak var describeView: UIView!
    @IBOutlet weak var describeViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var baseBackGroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.baseBackGroundView.alpha = 1
        }
        
    }
    
    private func setupViews() {
        self.view.bringSubviewToFront(videoImageView)
        
        imageViewCenterY = videoImageView.center.y
        
        channelImageView.layer.cornerRadius = 45 / 2
        
        if let url = URL(string: selectedItem?.snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: url, into: videoImageView)
        }
        
        if let channelUrl = URL(string: selectedItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: channelUrl, into: channelImageView)
        }
        
        videoTitleLabel.text = selectedItem?.snippet.title
        channelTitleLabel.text = selectedItem?.channel?.items[0].snippet.title
        
        let panGeture = UIPanGestureRecognizer(target: self, action: #selector(panVideoImageView))
        videoImageView.addGestureRecognizer(panGeture)
        
        print("videoImageMaxY: ", videoImageMaxY)
    }
    
    @objc private func panVideoImageView(gesture: UIPanGestureRecognizer) {
        
        guard let imageView = gesture.view else { return }
        let move = gesture.translation(in: imageView)
        
        if gesture.state == .changed {
            
            if videoImageMaxY <= move.y {
                moveToBottom(imageView: imageView as! UIImageView)
                return
            }
            
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
            videoImageBackView.transform = CGAffineTransform(translationX: 0, y: move.y)
            
            // 左右のpadding設定
            let movingConstant = move.y / 30
            
            if movingConstant <= 12 {
                videoImageViewTrailingConstraint.constant = -movingConstant
                videoImageViewLeadingConstraint.constant = movingConstant
                
                backViewTrailingConstraint.constant = -movingConstant
            }
            
            // imageViewの高さの動き
            // 280(最大値) - 70(最小値) = 210
            let parantViewHeight = self.view.frame.height
            let heightRatio = 210 / (parantViewHeight - (parantViewHeight / 6))
            let moveHeight = move.y * heightRatio
            
            backViewTopConstraint.constant = move.y
            videoImageViewHeightConstraint.constant = 280 - moveHeight
            describeViewTopConstraint.constant = move.y * 0.8
            
            let bottomMoveY = parantViewHeight - videoImageMaxY
            let bottomMoveRatio = bottomMoveY / videoImageMaxY
            let bottomMoveConstant = move.y * bottomMoveRatio
            backViewBottomConstraint.constant = bottomMoveConstant
            
            // alpha値の設定
            let alphaRatio = move.y / (parantViewHeight / 2)
            describeView.alpha = 1 - alphaRatio
            baseBackGroundView.alpha = 1 - alphaRatio
            
            // imageViewの横幅の動き 150(最小値)
            let originalWidth = self.view.frame.width
            let constant = originalWidth - move.y
            
            if minimumImageViewTrailingConstant > constant {
                videoImageViewTrailingConstraint.constant = minimumImageViewTrailingConstant
                return
            }
            
            if constant < -12 {
                videoImageViewTrailingConstraint.constant = constant
            }            
            
        } else if gesture.state == .ended {
            
            if move.y < self.view.frame.height / 3 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
                    
                    self.backToIdentityAllViews(imageView: imageView as! UIImageView)
                })
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                    
                    self.moveToBottom(imageView: imageView as! UIImageView)
                    
                }
            }
        }
    }
    
    private func moveToBottom(imageView: UIImageView) {
        // imageViewの設定
        imageView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        videoImageViewTrailingConstraint.constant = minimumImageViewTrailingConstant
        videoImageViewHeightConstraint.constant = 70
        
        videoImageBackView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        describeView.alpha = 0
        backView.alpha = 0
        baseBackGroundView.alpha = 0
        
        self.view.layoutIfNeeded()
    }
    
    private func backToIdentityAllViews(imageView: UIImageView) {
        // imageViewの設定
        imageView.transform = .identity
        videoImageViewHeightConstraint.constant = 280
        videoImageViewLeadingConstraint.constant = 0
        videoImageViewTrailingConstraint.constant = 0
        
        // backViewの設定
        backViewTrailingConstraint.constant = 0
        backViewBottomConstraint.constant = 0
        backViewTopConstraint.constant = 0
        backView.alpha = 1
        
        // describeViewの設定
        describeViewTopConstraint.constant = 0
        describeView.alpha = 1
        
        baseBackGroundView.alpha = 1
        
        self.view.layoutIfNeeded()
    }
    
}

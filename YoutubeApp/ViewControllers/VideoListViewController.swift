//
//  ViewController.swift
//  YoutubeApp
//
//  Created by Uske on 2020/07/05.
//  Copyright © 2020 Uske. All rights reserved.
//

import UIKit
import Alamofire

class VideoListViewController: UIViewController {

    // MARK: Propeties
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    private let headerMoveHeight: CGFloat = 5
    
    private let cellId = "cellId"
    private let atentionCellId = "atentionCellId"
    private var videoItems = [Item]()
    var selectedItem: Item?
    
    // MARK: IBOutlets
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var bottomVideoImageView: UIImageView!
    @IBOutlet weak var bottomVideoView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    // bottomImageViewの制約
    @IBOutlet weak var bottomVideoViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoImageHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSubscribeView: UIView!
    @IBOutlet weak var bottomCloseButton: UIButton!
    @IBOutlet weak var bottomVideoTitleLabel: UILabel!
    @IBOutlet weak var bottomVideoDescribeLabel: UILabel!
    
    // MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
//        fetchYoutubeSerachInfo()
        setupGestureRecognizer()
        setupNotifications()
    }
    
    // MARK: Methods
    @objc private func showThumbnailImage(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo as? [String: Any],
              let image = userInfo["image"] as? UIImage,
              let videoImageMinY = userInfo["videoImageMinY"] as? CGFloat else { return }
        
        let diffBottomConstant = videoImageMinY - self.bottomVideoView.frame.minY
        
        bottomVideoViewBottom.constant -= diffBottomConstant
        bottomSubscribeView.isHidden = false
        bottomVideoView.isHidden = false
        bottomVideoImageView.image = image
        bottomVideoTitleLabel.text = self.selectedItem?.snippet.title
        bottomVideoDescribeLabel.text = self.selectedItem?.snippet.description
        
    }
     
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showThumbnailImage), name: .init("thumbnailImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSearchedItem), name: .init("searchedItem"), object: nil)
    }
    
    @objc private func showSearchedItem() {
        let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
        
        videoViewController.selectedItem = self.selectedItem
        
        bottomVideoView.isHidden = true
        self.present(videoViewController, animated: true, completion: nil)
    }
    
    private func setupViews() {
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        videoListCollectionView.register(AttentionCell.self, forCellWithReuseIdentifier: atentionCellId)
        
        profileImageView.layer.cornerRadius = 20
        
        view.bringSubviewToFront(bottomVideoView)
        bottomVideoView.isHidden = true
        
        bottomCloseButton.addTarget(self, action: #selector(tappedCottomCloseButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(tappedSearchButton), for: .touchUpInside)
    }
    
    @objc private func tappedSearchButton() {
        let searchController = SearchViewController()
        let nav = UINavigationController(rootViewController: searchController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @objc private func tappedCottomCloseButton() {
        UIView.animate(withDuration: 0.2) {
            self.bottomVideoViewBottom.constant = -150
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.bottomVideoView.isHidden = true
            self.selectedItem = nil
        }
    }
    
}

// MARK: - API通信
extension VideoListViewController {
    
    private func fetchYoutubeSerachInfo() {
        let params = ["q": "lebronjames"]

        API.shared.request(path: .search, params: params, type: Video.self) { (video) in
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    
    
    private func fetchYoutubeChannelInfo(id: String) {
        let params = [
            "id": id
        ]
        
        API.shared.request(path: .channels, params: params, type: Channel.self) { (channel) in
            self.videoItems.forEach { (item) in
                item.channel = channel
            }
            
            self.videoListCollectionView.reloadData()
        }
    }
    
}

// MARK: - ScrollViewのDelegateメソッド
extension VideoListViewController {
    
    // scrollViewがscrollした時に呼ばれるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerAnimation(scrollView: scrollView)
    }
    
    private func headerAnimation(scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prevContentOffset = scrollView.contentOffset
        }
        
        guard let presentIndexPath = videoListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return }
        if scrollView.contentOffset.y < 0 { return }
        if presentIndexPath.row >= videoItems.count - 2 { return }
        
        let alphaRatio = 1 / headerHeightConstraint.constant
                
        if self.prevContentOffset.y < scrollView.contentOffset.y {
            if headerTopConstraint.constant <= -headerHeightConstraint.constant { return }
            headerTopConstraint.constant -= headerMoveHeight
            headerView.alpha -= alphaRatio * headerMoveHeight
        } else if self.prevContentOffset.y > scrollView.contentOffset.y {
            if headerTopConstraint.constant >= 0 { return }
            headerTopConstraint.constant += headerMoveHeight
            headerView.alpha += alphaRatio * headerMoveHeight
        }
        
    }
    
    // scrollViewのscrollがピタッと止まった時に呼ばれる
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            headerViewEndAnimation()
        }
    }
    
    // scrollViewが止まった時に呼ばれる
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerViewEndAnimation()
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
        
        if videoItems.count == 0 {
            videoViewController.selectedItem = nil
            self.selectedItem = nil
        } else {
            let item = indexPath.row > 2 ? videoItems[indexPath.row - 1] : videoItems[indexPath.row]
            videoViewController.selectedItem = item
            self.selectedItem = item
        }
        
        bottomVideoView.isHidden = true
        self.present(videoViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        if indexPath.row == 2 {
            return .init(width: width, height: 200)
        } else {
            return .init(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 2 {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: atentionCellId, for: indexPath) as! AttentionCell
            cell.videoItems = self.videoItems
            
            return cell
        } else {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
            
            if self.videoItems.count == 0 { return cell }
            
            if indexPath.row > 2 {
                cell.videoItem = videoItems[indexPath.row - 1]
            } else {
                cell.videoItem = videoItems[indexPath.row]
            }
            
            return cell
        }
    }
    
}

// MARK: - animation関連
extension VideoListViewController {
    
    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panBottomVideoView))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBottomVideoView))
        bottomVideoView.addGestureRecognizer(tapGesture)
        bottomVideoView.addGestureRecognizer(panGesture)
    }
    
    @objc private func panBottomVideoView(sender: UIPanGestureRecognizer) {
        let move = sender.translation(in: view)
        
        guard let imageView = sender.view else { return }
        
        if sender.state == .changed {
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                imageView.transform = .identity
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func tapBottomVideoView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
            self.bottomSubscribeView.isHidden = true
            self.bottomVideoViewExpandAnimation()
        } completion: { _ in
            let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
            videoViewController.selectedItem = self.selectedItem
            
            self.present(videoViewController, animated: false) {
                self.bottomVideoViewBackToIdentity()
            }
        }
    }
    
    private func bottomVideoViewExpandAnimation() {
        let topSafeArea = self.view.safeAreaInsets.top
        let bottomSafeArea = self.view.safeAreaInsets.bottom
        
        // bottomVideoView
        bottomVideoViewLeading.constant = 0
        bottomVideoViewTrailing.constant = 0
        bottomVideoViewBottom.constant = -bottomSafeArea
        bottomVideoViewHeight.constant = view.frame.height - topSafeArea
        
        // bottomVideoImageView
        bottomVideoImageWidth.constant = view.frame.width
        bottomVideoImageHeight.constant = 280
        
        self.tabBarController?.tabBar.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    private func bottomVideoViewBackToIdentity() {
        // bottomVideoView
        bottomVideoViewLeading.constant = 12
        bottomVideoViewTrailing.constant = 12
        bottomVideoViewBottom.constant = 20
        bottomVideoViewHeight.constant = 70
        
        // bottomVideoImageView
        bottomVideoImageWidth.constant = 150
        bottomVideoImageHeight.constant = 70
        
        bottomVideoView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func headerViewEndAnimation() {
        if headerTopConstraint.constant < -headerHeightConstraint.constant / 2 {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                
                self.headerTopConstraint.constant = -self.headerHeightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

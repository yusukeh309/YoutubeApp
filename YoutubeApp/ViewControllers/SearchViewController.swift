//
//  SearchViewController.swift
//  YoutubeApp
//
//  Created by Uske on 2021/01/02.
//  Copyright © 2021 Uske. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    private let videoCellId = "videoCellId"
    var video: Video?
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Youtubeを検索"
        sb.delegate = self
        return sb
    }()
    
    lazy var videoColletionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
        
        videoColletionView.frame = self.view.frame
        self.view.addSubview(videoColletionView)
        videoColletionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: videoCellId)
        
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        // TODO: api通信を呼ぶ
        let searchText = searchBar.text ?? ""
        fetchYoutubeSerachInfo(searchText: searchText)
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return video?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoColletionView.dequeueReusableCell(withReuseIdentifier: videoCellId, for: indexPath) as! VideoListCell
        cell.videoItem = video?.items[indexPath.row]
        return cell
    }
    
}

// MARK: - API通信
extension SearchViewController {
    
    private func fetchYoutubeSerachInfo(searchText: String) {
        let params = ["q": searchText]

        API.shared.request(path: .search, params: params, type: Video.self) { (video) in
            self.video = video
            self.fetchYoutubeChannelInfo()
        }
    }
    
    
    private func fetchYoutubeChannelInfo() {
        guard let video = self.video else { return }
        
        for (index, item) in video.items.enumerated() {
            let params = [
                "id": item.snippet.channelId
            ]

            API.shared.request(path: .channels, params: params, type: Channel.self) { (channel) in
                self.video?.items[index].channel = channel
                self.videoColletionView.reloadData()
            }
        }
    }
    
}

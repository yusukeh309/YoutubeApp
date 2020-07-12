//
//  Video.swift
//  YoutubeApp
//
//  Created by Uske on 2020/07/12.
//  Copyright © 2020 Uske. All rights reserved.
//

import Foundation

class Video: Decodable {
    
    let kind: String
    let items: [Item]
    
}

class Item: Decodable {
    
    var channel: Channel?
    let snippet: Snippet
    
}

class Snippet: Decodable {
    
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnail
    
}

class Thumbnail: Decodable {
    
    let medium: ThumbnailInfo
    let high: ThumbnailInfo
    
}

class ThumbnailInfo: Decodable {
    
    let url: String
    let width: Int?
    let height: Int?
    
}

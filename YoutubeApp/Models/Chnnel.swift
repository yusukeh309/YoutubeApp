//
//  Chnnel.swift
//  YoutubeApp
//
//  Created by Uske on 2020/07/12.
//  Copyright © 2020 Uske. All rights reserved.
//

import Foundation

class Channel: Decodable {
    
    let items: [ChannelItem]
    
}

class ChannelItem: Decodable {
    
    let snippet: ChannelSnippet
    
}

class ChannelSnippet: Decodable {
    
    let title: String
    let thumbnails: Thumbnail
    
}

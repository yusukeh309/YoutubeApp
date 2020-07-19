//
//  BaseTabBarController.swift
//  YoutubeApp
//
//  Created by Uske on 2020/07/19.
//  Copyright © 2020 Uske. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewControllers?.enumerated().forEach({ (index, viewController) in
            
            switch index {
            case 0:
                setTabbarInfo(viewController, selectedImageName: "home-icon-selected", unselectedImageName: "home-icon-unselected", title: "ホーム")
            case 1:
                setTabbarInfo(viewController, selectedImageName: "search-icon-selected", unselectedImageName: "search-icon-unselected", title: "検索")
            case 2:
                setTabbarInfo(viewController, selectedImageName: "channel-icon-selected", unselectedImageName: "channel-icon-unselected", title: "登録チャンネル")
            case 3:
                setTabbarInfo(viewController, selectedImageName: "inbox-icon-selected", unselectedImageName: "inbox-icon-unselected", title: "受信トレイ")
            case 4:
                setTabbarInfo(viewController, selectedImageName: "library-icon-selected", unselectedImageName: "library-icon-unselected", title: "ライブラリ")
            default:
                break
            }
        })
        
    }
    
    
    private func setTabbarInfo(_ viewController: UIViewController, selectedImageName: String, unselectedImageName: String, title: String) {
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
    
    
}

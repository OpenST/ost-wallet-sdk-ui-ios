//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstContent: NSObject {
    private static var instance: OstContent? = nil
    var contentConfig: [String: Any] = [:]
    
    class func getInstance() -> OstContent {
        var instance = OstContent.instance
        if nil == instance {
            instance = OstContent(contentConfig: [:])
        }
        return instance!
    }
    
    init(contentConfig: [String: Any]) {
        self.contentConfig = contentConfig
        super.init()
        OstContent.instance = self
    }
    
    func getNavBarLogo() -> UIImage {
        if let navLogoDict = contentConfig["image_nav_bar_logo"] as? [String: Any],
            let imageName = navLogoDict["name"] as? String {

            return UIImage(named: imageName)!
        }
        
        let imageName = (OstDefaultContent.content["image_nav_bar_logo"] as! [String: Any])["name"] as! String
        
        return getImageFromFramework(imageName: imageName)
    }
    
    func getImageFromFramework(imageName: String) -> UIImage {
        return UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }
    
    
}

@objc class OstDefaultContent: NSObject {
    static let content: [String: Any] = [
        "image_nav_bar_logo": [
            "name": "ost_nav_bar_logo",
            "url": ""
        ],
        "url_terms_and_condition": [
            "name": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. <tc>",
            "tc": ["name":"T&C Apply",
                   "url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"]
        ],
        
        "string_title": [
            "name": "title for this one"
        ]
        
        
    ]
}

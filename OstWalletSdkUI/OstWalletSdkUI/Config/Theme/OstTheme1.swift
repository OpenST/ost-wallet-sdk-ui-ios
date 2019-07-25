//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstTheme1: NSObject {
    private static var instance: OstTheme1? = nil
    var themeConfig: [String: Any] = [:]
    
    class func getInstance() -> OstTheme1 {
        var instance = OstTheme1.instance
        if nil == instance {
            instance = OstTheme1(themeConfig: [:])
        }
        return instance!
    }
    
    init(themeConfig: [String: Any]) {
        self.themeConfig = themeConfig
        super.init()
        OstTheme1.instance = self
    }
    
    
    /// Get `h1` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH1Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h1"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h1"] as! [String: Any])
    }
    
    /// Get `h2` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH2Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h2"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h2"] as! [String: Any])
    }
    
    /// Get `h3` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH3Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h3"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h3"] as! [String: Any])
    }
    
    /// Get `h4` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH4Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h4"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h4"] as! [String: Any])
    }
    
    /// Get `primary_button` theme config
    ///
    /// - Returns: OstButtonConfig
    func getPrimaryButtonConfig() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["primary_button"] as? [String: Any],
                                defaultConfig: OstDefaultTheme.theme["primary_button"] as! [String: Any])
    }
    
    /// Get `secondary_button` theme config
    ///
    /// - Returns: OstButtonConfig
    func getSecondaryButtonConfig() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["secondary_button"] as? [String: Any],
                                defaultConfig: OstDefaultTheme.theme["secondary_button"] as! [String: Any])
    }
}


@objc class OstDefaultTheme: NSObject {
    static let theme: [String: Any] = [
        "h1": ["size": 20,
               "font": "SFProDisplay-Semibold",
               "color": "#438bad"],
        
        "h2": ["size": 17,
               "font": "SFProDisplay-Medium",
               "color": "#666666"],
        
        "h3": ["size": 15,
               "font": "SFProDisplay-Regular",
               "color": "#888888"],
        
        "h4": ["size": 12,
               "font": "SFProDisplay-Regular",
               "color": "#888888"],
        
        "primary_button": ["background_color": ""],
        "secondary_button": ["background_color": ""]
    ]
}

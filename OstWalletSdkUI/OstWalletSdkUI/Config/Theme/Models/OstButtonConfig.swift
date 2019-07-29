//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstButtonConfig: OstBaseConfig {
    private let backgroundColor: UIColor
    
    override init(config: [String: Any]?,
                  defaultConfig: [String: Any]) {

        let colorStr = (config?["background_color"] as? String) ?? (defaultConfig["background_color"] as! String)
        self.backgroundColor = UIColor.color(hex: colorStr)
        
        super.init(config: config, defaultConfig: defaultConfig)
    }
    
    func getBackgroundColor() -> UIColor {
        return backgroundColor
    }
}

//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstBaseConfig: NSObject {
    
    let fontName: String
    let size: NSNumber
    let colorHex: String
    
    init(config: [String: Any]?,
         defaultConfig: [String: Any]) {
        
        self.fontName = (config?["font"] as? String) ?? ""
        self.size = (config?["size"] as? NSNumber) ?? (defaultConfig["size"] as! NSNumber)
        self.colorHex = (config?["color"] as? String) ?? (defaultConfig["color"] as! String)
    }
    
    func getFont(weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont(name: self.fontName, size: CGFloat(truncating: self.size)) ?? UIFont.systemFont(ofSize: CGFloat(truncating: self.size), weight: weight)
    }
    
    func getColor() -> UIColor {
        return UIColor.color(hex: colorHex)
    }
}

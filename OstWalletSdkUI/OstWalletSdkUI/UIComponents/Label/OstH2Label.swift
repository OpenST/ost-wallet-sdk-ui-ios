//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstH2Label: OstLabel1 {
    override func setThemeConfig() {
        self.labelConfig = OstTheme1.getInstance().getH2Config()
    }
    
    override func getFont() -> UIFont {
        return labelConfig!.getFont(weight: .medium)
    }
}

//
//  OstCurrentNavigation.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBlueNavigation: OstNavigation {
    
    override init() {
        super.init();
        self.fontProvider = OstFontProvider(fontName: "Lato")
        self.barTintColor = .white
        self.barTextColor = UIColor.color(97, 178, 214)
        self.backBarButtonImage = UIImage(named: "Back")!
    }
}

//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstLabel1: UILabel {
   
    var labelConfig: OstLabelConfig? = nil
    var labelText: String {
        didSet {
            self.text = labelText
        }
    }
    var labelAttributedText: NSAttributedString? = nil
    
    
    //MARK: - Initialize
    init(text: String = "") {
        self.labelText = text
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    init(attributedText: NSAttributedString) {
        self.labelText = ""
        self.labelAttributedText = attributedText
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    override init(frame: CGRect) {
        self.labelText = ""
        
        super.init(frame: frame)
        applyTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.labelText = ""
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    func applyTheme() {
        self.setThemeConfig()
        
        self.numberOfLines = 0
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .center
        
        self.font = labelConfig!.getFont()
        self.textColor = self.labelConfig!.getColor()
        
        if nil == labelAttributedText {
            self.text = self.labelText
        }else {
            self.attributedText = self.labelAttributedText!
        }
    }
    
    func setThemeConfig() {
        fatalError("setThemeConfig did not override")
    }
    
    func getFont() -> UIFont {
        fatalError("getFont did not override")
    }
}


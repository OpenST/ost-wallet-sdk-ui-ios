//
//  BaseTableViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseTableViewCell: UITableViewCell {
    
//    let containerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setVariables()
        
        createViews()
        applyConstraints()
        setValuesForComponents()
        
        self.selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setVariables()
        
        createViews()
        applyConstraints()
        
        setValuesForComponents()
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addToContentView(_ view: UIView) {
        self.contentView.addSubview(view)
    }

    //MARK: - Functions to override
    
    func setVariables() {}
    
    func createViews() {}

    func applyConstraints() {}
    
    func setValuesForComponents() {}
    
    func beingDisplay() {}
    
    func endDisplay() {}
    
}


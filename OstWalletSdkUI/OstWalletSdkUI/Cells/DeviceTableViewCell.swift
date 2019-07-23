/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class DeviceTableViewCell: UsersTableViewCell {
    
    static var deviceCellIdentifier: String {
        return "DeviceTableViewCell"
    }
    
    var overlayImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "DeviceIcon")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var tagLabel: UILabel = {
        let label = InsetLabel()
        label.font = OstTheme.fontProvider.get(size: 11)
        label.textColor = UIColor.color(52, 68, 91)
        label.backgroundColor = UIColor.color(231, 243, 248)
        label.layer.cornerRadius = 5
        label.textAlignment = .center
        label.clipsToBounds = true
        label.paddingWidth = 4
        label.paddingHeight = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    var sendButtonHeightConstraint: NSLayoutConstraint? = nil

    //MARK: - Add Subview
    override func createViews() {
        super.createViews()
        self.selectionStyle = .none
        self.detailsContainerView?.addSubview(tagLabel)
    }
    
    override func createInternalView() {
        self.circularView!.addSubview(overlayImage)
    }
    
    //MARK: - Apply Constraints
    override func applyConstraints() {
        super.applyConstraints()
        
        applyTagLabelConstraints()
    }
    
    override func applyInitialLetterConstraints() {
        self.overlayImage.centerYAnchor.constraint(equalTo: self.circularView!.centerYAnchor).isActive = true
        self.overlayImage.centerXAnchor.constraint(equalTo: self.circularView!.centerXAnchor).isActive = true
        self.overlayImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        self.overlayImage.heightAnchor.constraint(equalTo: (self.overlayImage.widthAnchor)).isActive = true
    }
    
    override func applyDetailsViewConstraints() {
        self.detailsContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.detailsContainerView?.leftAnchor.constraint(equalTo: self.circularView!.rightAnchor, constant: 8.0).isActive = true
        self.detailsContainerView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8.0).isActive = true
        self.detailsContainerView?.topAnchor.constraint(equalTo: circularView!.topAnchor, constant:4.0).isActive = true
    }
    
    override func applySendButtonConstraints() {
        self.sendButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton?.leftAnchor.constraint(equalTo: self.detailsContainerView!.leftAnchor).isActive = true
        self.sendButton?.topAnchor.constraint(equalTo: self.detailsContainerView!.bottomAnchor, constant:12.0).isActive = true
        self.sendButton?.bottomAnchor.constraint(equalTo: self.seperatorLine!.topAnchor, constant:-12.0).isActive = true
        sendButtonHeightConstraint = self.sendButton?.heightAnchor.constraint(equalToConstant: 30.0)
        sendButtonHeightConstraint?.isActive = true
    }
    
    override func applyTitleLabelConstraitns() {
        guard let parent = self.titleLabel?.superview else {return}
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.titleLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
    }
    
    func applyTagLabelConstraints() {
        guard let parent = self.titleLabel?.superview else {return}
        self.tagLabel.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.tagLabel.leftAnchor.constraint(equalTo: titleLabel!.rightAnchor, constant: 10).isActive = true
        self.tagLabel.centerYAnchor.constraint(equalTo: titleLabel!.centerYAnchor).isActive = true
    }
}

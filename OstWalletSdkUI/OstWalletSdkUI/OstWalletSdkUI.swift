/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

@objc public class OstWalletSdkUI: NSObject {
    
    @objc
    public class func setThemeConfig(_ config: [String: Any]) {
        _ = OstTheme1(themeConfig: config)
    }
    
    @objc
    public class func setContentConfig(_ config: [String: Any]) {
        _ = OstContent(contentConfig: config)
    }
    
    @objc
    public class func activateUser(
        userId: String,
        expireAfterInSec: TimeInterval,
        spendingLimit: String,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstActivateUserWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            spendingLimit: spendingLimit,
            expireAfterInSec: expireAfterInSec)
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        
        return workflowController.workflowId
    }
    
    @objc
    public class func initaiteDeviceRecovery(
        userId: String,
        recoverDeviceAddress: String? = nil,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstInitiateDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            recoverDeviceAddress: recoverDeviceAddress)
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        
        return workflowController.workflowId
    }
    
    @objc
    public class func abortDeviceRecovery(
        userId: String,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstAbortDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate
        )
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        
        return workflowController.workflowId
    }
    
    @objc
    public class func subscribe(workflowId: String,
                                listner: OstWorkflowUIDelegate) {
        
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowId,
                                             listner: listner)
    }
    
    @objc
    public class func unsubscribe(workflowId: String,
                                  listner: OstWorkflowUIDelegate) {
        
        OstSdkInteract.getInstance.unsubscribe(forWorkflowId: workflowId,
                                               listner: listner)
    }
}

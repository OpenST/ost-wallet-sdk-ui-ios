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
    public class func activateUser(
        userId: String,
        spendingLimit: String,
        expireAfterInSec: TimeInterval,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate,
        subscriber: OstWorkflowUIDelegate? = nil
        ) -> OstWorkflowCallbacks {
        
        let workflowController = OstActivateUserWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            spendingLimit: spendingLimit,
            expireAfterInSec: expireAfterInSec)
        
        _ = retainAndSubscribeWorkflow(workflowController: workflowController,
                                          subscriber: subscriber)
        
        return workflowController
    }
    
    @objc
    public class func initaiteDeviceRecovery(
        userId: String,
        recoverDeviceAddress: String? = nil,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate,
        subscriber: OstWorkflowUIDelegate? = nil
        ) -> OstWorkflow {
        
        let workflowController = OstInitiateDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            recoverDeviceAddress: recoverDeviceAddress)
        
        return retainAndSubscribeWorkflow(workflowController: workflowController,
                                          subscriber: subscriber)
    }
    
    @objc
    public class func abortDeviceRecovery(
        userId: String,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate,
        subscriber: OstWorkflowUIDelegate? = nil
        ) -> OstWorkflow {
        
        let workflowController = OstAbortDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate
        )
        
        return retainAndSubscribeWorkflow(workflowController: workflowController,
                                          subscriber: subscriber)
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
    
    
    //MARK: - Retain And Subscribe
    private class func retainAndSubscribeWorkflow(
        workflowController: OstWorkflowCallbacks,
        subscriber: OstWorkflowUIDelegate?
        ) -> OstWorkflow {
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        if (nil != subscriber) {
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowController.workflowId,
                                                 listner: subscriber!)
        }
        
        let workflow = OstWorkflow(workflowCallbacks: workflowController)
        return workflow;
    }
    
}

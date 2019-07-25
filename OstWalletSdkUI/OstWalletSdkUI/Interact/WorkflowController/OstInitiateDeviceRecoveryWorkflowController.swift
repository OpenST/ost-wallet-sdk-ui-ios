/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class OstInitiateDeviceRecoveryWorkflowController: OstWorkflowCallbacks {
    
    var recoverDeviceAddress: String?
    var deviceListController: OstAuthorizeDeviceListViewController? = nil
    /// Mark - View Controllers.
    
    init(userId: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate,
         recoverDeviceAddress: String?) {
       
        self.recoverDeviceAddress = recoverDeviceAddress
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
        
        self.observeViewControllerIsMovingFromParent()
        
        if nil == recoverDeviceAddress {
            self.openAuthorizeDeviceListController()
        } else {
            self.openGetPinViewController()
        }
    }
    
    deinit {
        print("OstInitiateDeviceRecoveryWorkflowController :: I am deinit ");
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        
        var isFlowCancelled: Bool = false
        if (nil == self.deviceListController && notification.object is OstCreatePinViewController)
            || (nil != self.deviceListController && notification.object is OstAuthorizeDeviceListViewController) {
         
            isFlowCancelled = true
        }
        
       if ( isFlowCancelled ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .initiateDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    func setGetPinViewController() {
        self.getPinViewController = OstCreatePinViewController.newInstance(pinInputDelegate: self);
    }
    
    func openAuthorizeDeviceListController() {
        self.deviceListController = OstAuthorizeDeviceListViewController.newInstance(callBack: {[weak self] (device) in
            //self?.recoverDeviceAddress = ""
            self?.openGetPinViewController()
        })

        self.deviceListController!.presentVCWithNavigation()
    }
    
    func openGetPinViewController() {
        setGetPinViewController()
        if nil == deviceListController {
             self.getPinViewController!.presentVCWithNavigation()
        }else {
            self.getPinViewController!.pushViewControllerOn(self.deviceListController!)
        }
    }
    
    //MARK: - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
   
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .initiateDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            return;
        }
        
        OstWalletSdk.initiateDeviceRecovery(userId: self.userId,
                                            recoverDeviceAddress: self.recoverDeviceAddress!,
                                            userPin: self.userPin!,
                                            passphrasePrefix: passphrase,
                                            delegate: self)
        self.userPin = nil;
        showLoader(progressText: .initiateDeviceRecovery);
    }
    
    //MARK: - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        self.userPin = pin;
        showLoader(progressText: .initiateDeviceRecovery);
        passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId,
                                                passphrasePrefixAcceptDelegate: self);
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.deviceListController ) {
            self.deviceListController?.removeViewController()
        }
        self.getPinViewController = nil
        self.passphrasePrefixDelegate = nil
        self.deviceListController = nil
        NotificationCenter.default.removeObserver(self)
    }
}

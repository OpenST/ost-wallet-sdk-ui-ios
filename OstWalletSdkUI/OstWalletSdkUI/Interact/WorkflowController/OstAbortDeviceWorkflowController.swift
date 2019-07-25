/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstAbortDeviceRecoveryWorkflowController: OstWorkflowCallbacks {
    
    /// Mark - View Controllers.
    
    override init(userId: String,
                  passphrasePrefixDelegate:OstPassphrasePrefixDelegate) {
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
        
        self.getPinViewController = OstCreatePinViewController.newInstance(pinInputDelegate: self);
        self.observeViewControllerIsMovingFromParent();
        
        self.getPinViewController!.presentVCWithNavigation()
    }
    
    deinit {
        print("OstAbortDeviceRecoveryWorkflowController :: I am deinit");
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstCreatePinViewController ) {
            self.getPinViewController = nil;
            //The workflow has been cancled by user.
            
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .abortDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .abortDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        
        showLoader(progressText: .stopDeviceRecovery)
        OstWalletSdk.abortDeviceRecovery(userId: self.userId,
                                         userPin: self.userPin!,
                                         passphrasePrefix: passphrase,
                                         delegate: self)
        self.userPin = nil;
        
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        self.userPin = pin;
        showLoader(progressText: .stopDeviceRecovery);
        passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId,
                                                passphrasePrefixAcceptDelegate: self);
    }
    
    public override func cleanUpPinViewController() {
        self.sdkPinAcceptDelegate = nil;
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.getPinViewController ) {
            self.getPinViewController?.removeViewController();
        }
        self.getPinViewController = nil;
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }
}
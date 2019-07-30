//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

@objc class OstBaseWorkflowController: OstWorkflowCallbacks {
    
    var currentUser: OstUser? = nil
    var currentDevice: OstDevice? = nil
    
    func perform() {
        do {
            //Set user and device
            setVariables()
            
            self.observeViewControllerIsMovingFromParent()
            try performUserDeviceValidation()
        }catch let err {
            postFlowInterrupted(error: err as! OstError)
        }
    }
    
    func setVariables() {
        self.currentUser = OstWalletSdk.getUser(self.userId)
        self.currentDevice = self.currentUser?.getCurrentDevice()
    }
    
    func performUserDeviceValidation() throws {
        if !self.currentUser!.isStatusActivated {
            throw OstError("i_wc_bwc_pudv_1", .userNotActivated)
        }
    }
    
    func postFlowInterrupted(error: OstError) {
        self.flowInterrupted(workflowContext: getWorkflowContext(),
                             error: error)
    }
}

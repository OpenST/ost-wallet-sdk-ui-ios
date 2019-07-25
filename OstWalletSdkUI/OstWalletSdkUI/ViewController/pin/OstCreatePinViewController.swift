/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit
import OstWalletSdk;


class OstCreatePinViewController: OstPinViewController {
    
    public override class func newInstance(pinInputDelegate: OstPinInputDelegate) -> OstCreatePinViewController {
        let instance = OstCreatePinViewController();
        setEssentials(instance: instance, pinInputDelegate: pinInputDelegate);
        return instance;
    }
    
    class func setEssentials(instance: OstCreatePinViewController, pinInputDelegate: OstPinInputDelegate) {
        instance.pinInputDelegate = pinInputDelegate;
    }
    
    override func getTitleLabelText() -> String {
        return "Enter Pin"
    }
    
    override func getLeadLabelText() -> String {
        return "Enter you 6-digit PIN to authorize \n your action."
    }
    
    override func getH3LabelText() -> String {
        return "(PIN helps you recover your wallet if the \n phone is lost or stolen)"
    }
}

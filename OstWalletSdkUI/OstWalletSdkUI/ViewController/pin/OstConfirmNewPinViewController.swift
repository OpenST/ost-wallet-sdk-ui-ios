/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit
import OstWalletSdk;

class OstConfirmNewPinViewController: OstPinViewController {

    public override class func newInstance(pinInputDelegate: OstPinInputDelegate) -> OstConfirmNewPinViewController {
        let instance = OstConfirmNewPinViewController();
        setEssentials(instance: instance, pinInputDelegate: pinInputDelegate);
        return instance;
    }
    
    override func getTitleLabelText() -> String {
        return "Confirm PIN"
    }
    
    override func getLeadLabelText() -> String {
        return "If you forget your PIN, you cannot recover your wallet."
    }
    
    override func getH3LabelText() -> String {
        return "(So please be sure to remember it)"
    }
}

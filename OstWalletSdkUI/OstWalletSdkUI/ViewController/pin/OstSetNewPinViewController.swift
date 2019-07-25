/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit

class OstSetNewPinViewController: OstPinViewController {
    public override class func newInstance(pinInputDelegate:OstPinInputDelegate) -> OstSetNewPinViewController {
        let instance = OstSetNewPinViewController();
        setEssentials(instance: instance, pinInputDelegate: pinInputDelegate);
        return instance;
    }
}

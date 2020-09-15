/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation
import UIKit
protocol CanConfigureEconomyProtocol {
    func defaultEconomySet(payload:[String:Any?]);
    func newEconomySet(payload:[String:Any?]);
    func newEconomyNotSet();
    func sameEconomySet();
    func clearAppUrlData();
}

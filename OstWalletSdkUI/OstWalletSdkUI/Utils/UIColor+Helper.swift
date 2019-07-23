/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension UIColor {
    public class func color(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Float = 1.0) -> UIColor {
        let f255 = CGFloat(255);
        let r = CGFloat( red ) / f255;
        let g = CGFloat( green ) / f255;
        let b = CGFloat( blue ) / f255;
        let a = CGFloat( alpha );
        return UIColor(red: r, green: g, blue: b, alpha: a);
    }
}

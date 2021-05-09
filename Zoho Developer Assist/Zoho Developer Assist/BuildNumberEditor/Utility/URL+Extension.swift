//
//  URL+Extension.swift
//  Localization Helper
//
//  Created by Tharun P on 17/08/20.
//  Copyright © 2020 Tharun P. All rights reserved.
//

import Foundation

extension URL
{
    var string: String {
        return self.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
}

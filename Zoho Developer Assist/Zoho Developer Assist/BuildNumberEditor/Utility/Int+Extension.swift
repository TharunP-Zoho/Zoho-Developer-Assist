//
//  Int+Extension.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 30/05/21.
//

import Foundation

extension Int
{
    var safeValue: Int
    {
        if self < 0
        {
            return 0
        }
        
        return  self
    }
}

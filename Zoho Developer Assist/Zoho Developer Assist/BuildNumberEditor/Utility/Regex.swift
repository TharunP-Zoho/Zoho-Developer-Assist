//
//  Regex.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 09/05/21.
//

import Foundation

class Regex
{
    class func matches(for expression: String, soruce: String) -> [String]
    {
        var result = [String]()
        
        let regex = try? NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.caseInsensitive)
        if let regex = regex
        {
            let matches = regex.matches(in: soruce, options: [], range: NSRange(location: 0, length: soruce.utf16.count))
            
            for matche in matches
            {
                if let range = Range(matche.range(at: 0), in: soruce)
                {
                    result.append(String(soruce[range]))
                }
            }
        }
        
        return result
    }
}

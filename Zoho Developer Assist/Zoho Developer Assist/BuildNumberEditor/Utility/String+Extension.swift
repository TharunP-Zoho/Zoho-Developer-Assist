//
//  String+Extension.swift
//  Localization Helper
//
//  Created by Tharun P on 17/08/20.
//  Copyright © 2020 Tharun P. All rights reserved.
//

import Foundation

extension String {
    
    var fileName: String
    {
        String(self.split(separator: "/").last ??  "")
    }
    
    var removeExtension: String
    {
        var subStrings = self.split(separator: ".")
        
        if subStrings.count > 1
        {
            subStrings.removeLast()
        }
        
        return String(subStrings.joined(separator: "."))
    }

    func slice(from: String, to: String, completionHnadler: ((Range<String.Index>) -> Void)? = nil) -> String?
    {
        var value: String?
        var ranges: Range<String.Index>?
        
       let _ = (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                value = String(self[substringFrom..<substringTo])
                let newSubstringFrom = self.index(before: substringFrom)
                ranges = newSubstringFrom..<substringFrom
            }
        }
        
        if let handler = completionHnadler
        {
            if let ranges = ranges
            {
                handler(ranges)
            }
        }
        
        return value
    }
    
    
    func getSectionInProjectFile(sectionName: String) -> String
    {
        let configBegin = "/* Begin \(sectionName) section */"
        let configEnd = "/* End \(sectionName) section */"
        
        return self.slice(from: configBegin, to: configEnd) ?? ""
    }
    
    //MARK:- BuildNumber Changing Func
    
    func getBuildNumberType() -> BuildNumberType
    {
        if self.contains(".")
        {
            return .combineLastTwoWithHunderMutiple
        }
        
        return .plain
    }
    
    func getIncreasedLastDigit(for increament: Int) -> String?
    {
         var components = self.components(separatedBy: ".")
        
         if let lastValue = components.last
         {
            if let integer = Int(lastValue)
            {
                let newInteger = "\((integer + increament).safeValue)"
                
                components.removeLast()
                components.append(newInteger)
                
                return components.joined(separator: ".")
            }
         }
        
        return nil
    }
    
    func getIncreasedVersionNumber(for increament: Int, position: Postion) -> String?
    {
        switch position
        {
        case .last:
            return getIncreasedLastDigit(for: increament)
        case .other(let place):
            
            let components = self.components(separatedBy: ".")
            
            if place < components.count
            {
               if let integer = Int(components[place-1])
               {
                let newInteger = "\((integer + increament).safeValue)"
                   
                    var temp = [String]()
                
                    for i in 1...components.count
                    {
                        if i < place
                        {
                            temp.append(components[i-1])
                        }
                        else if i == place
                        {
                            temp.append(newInteger)
                        }
                        else if i > place
                        {
                            temp.append("0")
                        }
                    }
                   
                   return temp.joined(separator: ".")
               }
            }
            else if place == components.count
            {
                return getIncreasedLastDigit(for: increament)
            }
            
        }
       
       return nil
    }
    
    
    func getBuildNumberFromVersion(type: BuildNumberType) -> String?
    {
       switch type {
       case .plain:
           return "0"
       case .combineLastTwoWithHunderMutiple:
            
        let components = self.components(separatedBy: ".")
        if components.count > 2
        {
            if let fristDouble = Double("\(components[0]).\(components[1])")
            {
                
                var tempString = [String]()
                for i in 1...components.count
                {
                    if i == 1
                    {
                        tempString.append("\(Int(fristDouble * 100))")
                    }
                    else if i == components.count
                    {
                        tempString.append("0")
                    }
                    else if i > 1
                    {
                        tempString.append(components[i])
                    }
                }
                
                return tempString.joined(separator: ".")
            }
        }
           
       }
        
        return nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK:- Unwanted
    
    func checkIfTextContains() -> Bool
    {
        if self.isEmpty
        {
            return false
        }
        if let _ = Int(self)
        {
            return false
        }
        if let _ = Double(self)
        {
            return false
        }
        if self == self.uppercased()
        {
            return false
        }
        if self == "\\(i)" || self == "0\\(i)"
        {
            return false
        }
        if self.contains("Utility.getLocalizedString")
        {
            return false
        }
        
        return true
    }
    
    mutating func prepareForProcess()
    {
        self = self.replacingOccurrences(of: "\\\"", with: "இ") //இ used this rare string for avoid coincidence
        
        var temp = ""
        
        var isInsideString = false
        var isStringInsideInterploation = false
        var isInsideInterpolation = false
        var isAppended = false
        
        var tempSlashCheck = false
        
        for char in self
        {
            isAppended = false
            
            if char == "\"" && isInsideString
            {
                isInsideString = false
            }
            else if char == "\"" && !isInsideString
            {
                isInsideString = true
            }
            
            if tempSlashCheck && char == "("
            {
                temp.append("அ") //அ used this rare string for avoid coincidence
                isInsideInterpolation = true
                isAppended = true
            }
            
            if isInsideInterpolation && char == ")"
            {
                temp.append("ஆ") //ஆ used this rare string for avoid coincidence
                isInsideInterpolation = false
                isAppended = true
            }
            
            if isInsideInterpolation && char == "\"" && isStringInsideInterploation
            {
                temp.append("ஈ")
                isStringInsideInterploation = false
                isAppended = true
            }
            else if isInsideInterpolation && char == "\"" && !isStringInsideInterploation
            {
                temp.append("ஈ")
                isStringInsideInterploation = true
                isAppended = true
            }
            
            if !isAppended
            {
                temp.append(char)
            }
            
            tempSlashCheck = false
            if isInsideString && char == "\\"
            {
                tempSlashCheck = true
            }
            
        }
        
        self = temp
        self = self.replacingOccurrences(of: "\\அ", with: "அ")
    }
    
    mutating func prepareToDispaly()
    {
        self = self.replacingOccurrences(of: "அ", with: "\\(")
        self = self.replacingOccurrences(of: "ஆ", with: ")")
        self = self.replacingOccurrences(of: "இ", with: "\\\"")
        self = self.replacingOccurrences(of: "ஈ", with: "\"")
    }
    
    func getGroupName() -> String
    {
        var ignore = 0
        var groupName = ""
        
        for char in self
        {
            if char == "/"
            {
                ignore += 1
            }
            if ignore == 2
            {
                return groupName.replacingOccurrences(of: "/", with: " -> ")
            }
            else
            {
                groupName.append(char)
            }
        }
        
        return ""
     }
    
    func getLangName() -> String
    {
        var lang = ""
        let temp = self.slice(from: "/", to: ".lproj") ?? ""
        
        for char in temp.reversed()
        {
            if char == "/"
            {
               
                return lang
            }
            else
            {
                lang.insert(char, at: lang.startIndex)
            }
        }
        return ""
    }
    
    func getWebLangName() -> String
    {
        let languageCode = ["de", "en", "es", "fr", "id", "it", "ja", "nl", "pt_br", "pt", "sv", "th", "vi", "zh-Hans", "zh"]
        
        for lang in languageCode
        {
            if self.contains("\(lang).properties")
            {
                return lang
            }
        }
        return ""
    }
    
    func langName() -> String
    {
        let languageCode = ["de", "en", "es", "fr", "id", "it", "ja", "nl", "pt-BR", "pt-PT", "sv", "th", "vi", "zh-Hans", "zh"]
        let languageName = ["German", "English", "Spanish", "French", "Indonesian", "italain", "Japanese", "Dutch", "Portuguese", "Portuguese(Brazil)", "Swedish", "Thai", "Vietnamese", "Chinese(Simplified)", "Chinese"]
        
        for (index,lang) in languageCode.enumerated()
        {
            if lang == self
            {
                return languageName[index]
            }
        }
        
        return self
    }
    
    func characterCount(character: Character) -> Int
    {
        var count = 0
        
        for char in self
        {
            if char == character
            {
                count += 1
            }
        }
        
        return count
    }

}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
            
        }

        return result
    }
    
    func returnDuplicates() -> [Element] {
           var temp = [Element]()
        var result = [Element]()
           for value in self {
               if temp.contains(value) == false {
                   temp.append(value)
               }
            else
               {
                result.append(value)
            }
               
           }

           return result
       }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

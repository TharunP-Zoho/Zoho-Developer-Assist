//
//  FileParser.swift
//  Localization Helper
//
//  Created by Tharun P on 17/08/20.
//  Copyright © 2020 Tharun P. All rights reserved.
//

import Foundation


class FileParser
{
    enum FileExtension: String
    {
        case swift
        case strings
        case properties
        case stringsdict
        case exceptSwift
        case xcodeproj
    }

    class func getFilesList(url: URL, for fileExtension: FileExtension) -> [URL]
    {
        let filePaths = FileManager.default.getAllFilesRecursively(url: url).filter{ path in
             path.pathExtension == fileExtension.rawValue
        }
        let filePathss = FileManager.default.getAllFilesRecursively(url: url)
        if filePaths.isEmpty
        {
            print("Please enter the correct URL")
        }
        
        //Test
        var allExtension = [""]
        let solvedExtension = ["strings", "", "stringsdict", "swift", "bundle", "intentdefinition", "storyboard", "framework", "xcframework", "storyboardc", "png", "lproj", "json", "nib", "plist", "imageset", "gif", "pdf", "xib", "jpg", "js", "xcdatamodeld", "ttf", "colorset", "h", "xcassets", "swiftinterface", "swiftmodule"]
        //
        
        if fileExtension == .strings
        {
            var stringFile = [URL]()
            
            for path in filePaths
            {
                if path.string.contains("/Localizable.strings") || path.string.contains("/Base.strings") || path.string.contains(".strings")
                {
                    stringFile.append(path)
                }
            }
            return stringFile
        }
        else if fileExtension == .exceptSwift
        {
            var stringFile = [URL]()
            
            for path in filePathss
            {
                if !solvedExtension.contains(path.pathExtension)
                {
                    stringFile.append(path)
                    if !allExtension.contains(path.pathExtension)
                    {
                        allExtension.append(path.pathExtension)
                    }
                }
            }
            print(allExtension.count)
            return stringFile
        }
        
        return filePaths
    }
    
    

    class func getListOfStringForEmptyKeyInLocalizationMethod(paths: [URL]) -> [String]
    {
        
        var stringForKeys: [String] = []
        for path in paths
        {
            stringForKeys += getListOfStringForEmptyKeyInLocalizationMethod(path: path)
        }
        return stringForKeys
    }
    
    class func getListOfStringForEmptyKeyInLocalizationMethod(path: URL) -> [String]
    {
        let trimForm = "Utility.getLocalizedString(\"\", value: \""
        let trimTo = "\")"
        var stringForKeys: [String] = []
        
        do
        {
            var stringOfFile = try String(contentsOfFile: path.string)
            for _ in 0...
            {
                if let value = stringOfFile.slice(from: trimForm, to: trimTo){ranges in
                    stringOfFile.replaceSubrange(ranges, with: "%")
                }
                {
                    //test
                    if value == "service is over" || value == "service is over"
                    {
                        print(stringOfFile)
                    }
                    
                    //end
                    
                    stringForKeys.append(value)
                }
                else
                {
                    return stringForKeys
                }
            }
            
        }
        catch
        {
            print("Error on converting to string of filePath : \(path)")
        }
        return stringForKeys
    }
    
    
    
    
    class func getListOfStringUsedDriectly(paths: [URL]) -> [String]
    {
        var stringForKeys: [String] = []
        for path in paths
        {
            stringForKeys += getListOfStringUsedDriectly(path: path)
        }
        return stringForKeys
    }
    
    class func getListOfStringUsedDriectly(path: URL) -> [String]
    {
        let trimFromArray = [".title=\"",".subtitle=\"",".body=\"",".setTitle(\"",".placeholder=\"","(title:\"","message:\""]
        let trimTo = "\""
        var stringForKeys: [String] = []
        
        do
        {
            let stringOfFile = try String(contentsOfFile: path.string)
            var stringWithOutSpace = removeSpacingInTheString(stringOfFile)
            stringWithOutSpace.prepareForProcess()
            
            for trimFrom in trimFromArray
            {
                stringForKeys += doLoopWith(string: stringWithOutSpace, trimFrom: trimFrom, trimTo: trimTo)
            }
        }
        catch
        {
            print("Error on converting to string of filePath : \(path)")
        }
        return stringForKeys
    }
    
    class func doLoopWith(string: String, trimFrom: String, trimTo: String) -> [String]
    {
        var stringWithOutSpace = string
        var stringForKeys = [String]()
        
        for _ in 0...
        {
            if let value = stringWithOutSpace.slice(from: trimFrom, to: trimTo){ranges in
                stringWithOutSpace.replaceSubrange(ranges, with: "%")
            }
            {
                var valueForDisplay = value
                valueForDisplay.prepareToDispaly()
                stringForKeys.append(valueForDisplay)
            }
            else
            {
                return stringForKeys
            }
        }
        
        return stringForKeys
    }
    
    class func removeSpacingInTheString(_ file:String) -> String
    {
        var isInsideString = false
        
        var string = ""
        
        let file = file.replacingOccurrences(of: "\\\"", with: "%%")
        
        for char in file
        {
            if char == "\"" && isInsideString
            {
                isInsideString = false
            }
            else if char == "\"" && !isInsideString
            {
                isInsideString = true
            }
            
            if isInsideString == false
            {
                if char != " "
                {
                    string.append(char)
                }
            }
            else
            {
                string.append(char)
            }
            
        }
    
        let strings = string.replacingOccurrences(of: "%%", with: "\\\"")
        
        return strings
    }
    
    class func getKeysinThefiles(_ paths: [URL]) -> [String]
    {
        var allKeys = [String]()
        
        for path in paths
        {
            do
            {
                var stringOfFile = try String(contentsOfFile: path.string)

                if let value = stringOfFile.slice(from: "Utility.getLocalizedString(\"", to: "\""){ranges in
                    stringOfFile.replaceSubrange(ranges, with: "%")
                }
                {
                    if !allKeys.contains(value)
                    {
                        allKeys.append(String(value))
                    }
                }
            }
            catch
            {
                print("Error on converting to string of filePath : \(path)")
            }
            
        }
        
        return allKeys
    }
    
}

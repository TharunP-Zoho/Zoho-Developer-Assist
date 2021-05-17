//
//  FileManager+Extension.swift
//  Localization Helper
//
//  Created by Tharun P on 17/08/20.
//  Copyright © 2020 Tharun P. All rights reserved.
//

import Foundation

extension FileManager
{
    
    func getAllFilesRecursively(url: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(atPath: url.path) else {
            return []
        }

        return enumerator.compactMap({ element -> URL? in
            guard let path = element as? String else {
                return nil
            }

            return url.appendingPathComponent(path, isDirectory: false)
        })
    }
    
    func readFile(url: String, errorHandler: (CustomError) -> Void) -> String
    {
        var fileContent = ""
        
        do
        {
            try fileContent = String(contentsOf: URL(fileURLWithPath: url))
        }
        catch
        {
            errorHandler(CustomError(title: "File Path Incorrect", description: error.localizedDescription))
        }
        
        return fileContent
    }
}


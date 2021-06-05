//
//  Terminal.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 01/06/21.
//

import Foundation

struct Bash
{
    @discardableResult
    static func runShell(_ args: String) -> (code: Int32, result: String) {
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args]
        task.launch()
        task.waitUntilExit()
        task.terminate()
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return (task.terminationStatus, output)
    }
}

struct Git
{
    var repoLocation = ""
    {
        didSet
        {
            if repoLocation.last != "/"
            {
                repoLocation = repoLocation + "/"
            }
        }
    }
    
    func cmd(_ command: String) -> (code: Int32, result: String)
    {
        Bash.runShell("git --git-dir=\(repoLocation).git --work-tree=\(repoLocation) \(command)")
    }
}

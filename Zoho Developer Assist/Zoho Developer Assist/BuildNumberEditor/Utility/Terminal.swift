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
    
    func statusCheck() -> Result<String, CustomError>
    {
        let status = cmd("status")
        
        if status.code == 0
        {
            if status.result.contains("nothing to commit")
            {
                return .success("")
            }
            else if status.result.contains("Changes to be committed:") || status.result.contains("Untracked files:")
            {
                return .failure(CustomError(title: "Uncommitted changed found in Git", description: "Looks like some of the changes is not committed, please commit the changes and try again or discard the changes"))
            }
        }
        else if status.code == 1
        {
            if status.result.contains("SSL certificate")
            {
                return .failure(CustomError(title: "VPN is not Connected", description: "Please connect your VPN and try again"))
            }
        }
        
        return .failure(CustomError(title: "Something went wrong, Check the below git result", description: status.result))
    }
    
    func newBranch(branchName: String) -> Result<String, CustomError>
    {
        let status = cmd("checkout -b changing_build_number_to_\(branchName)")
        
        if status.code == 0
        {
            if status.result.contains("Switched to a new branch")
            {
                return .success("")
            }
        }
        
        return .failure(CustomError(title: "Unable to create branch", description: status.result))
    }
    
    func commitAndPush(msg: String) -> Result<String, CustomError>
    {
        let stageStatus = cmd("add --all")
        let commitStatus = cmd("commit -m \"\(msg)\"")
        
        if stageStatus.code == 0
        {
            if commitStatus.code == 0
            {
                let pushStatus = cmd("push")
                
                if pushStatus.code == 0
                {
                    return .success("")
                }
                return .failure(CustomError(title: "Unable to push", description: pushStatus.result))
            }
            return .failure(CustomError(title: "Unable to commit", description: commitStatus.result))
        }
        return .failure(CustomError(title: "Unable to commit", description: stageStatus.result))
    }
    
    func raiseMR(title: String, descripition: String, targetBranch: String, assinee: String?) -> Result<String, CustomError>
    {
        var command = "push -o merge_request.create -o merge_request.title=\(title) -o merge_request.description=\(descripition) -o merge_request.target=\(targetBranch)"
        
        if let assinee = assinee
        {
            command += " -o merge_request.assign=\(assinee)"
        }
        
        let status = cmd(command)
        
        if status.code == 0
        {
            return .success("")
        }
        
        return .failure(CustomError(title: "Unable to Raise MR", description: status.result))
    }
    
    func brachList(needMore: Bool = false) -> Result<[String], CustomError>
    {
        var command = "branch"
        
        if needMore
        {
            command += " -a"
        }
        
        let status = cmd(command)
        
        if status.code == 0
        {
            return .success(status.result.components(separatedBy: "\n"))
        }
        
        return .failure(CustomError(title: "Unable to fetch branch list", description: status.result))
    }
}

struct XCodeBuild
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
    
    private var getFileType: String
    {
        guard let fileName = repoLocation.components(separatedBy: "/").last else { return "" }
        if fileName.contains("xcproject")
        {
            return "project"
        }
        else if fileName.contains("xcworkspace")
        {
            return "workspace"
        }
        
        return ""
    }
    
    func cmd(_ commands: String...) -> (code: Int32, result: String)
    {
        var resultcommand = "xcode -\(getFileType) \(repoLocation)"
        
        for command in commands
        {
            resultcommand += " -\(command)"
        }
        
        return Bash.runShell(resultcommand)
    }
}

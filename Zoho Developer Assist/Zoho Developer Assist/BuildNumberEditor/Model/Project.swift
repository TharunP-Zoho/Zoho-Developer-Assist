//
//  Project.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 05/06/21.
//

import Foundation

struct Project: Hashable
{
    var file = ""
    var targets = [Target]()
    var selected = false
    var isManualValue = false
    var commonValue = ""
    var sampleBuildNumber = ""
    var sampleVersionNumber = ""
    var incrementalValue = 0
    
    mutating func computeValue(postion: Postion, isBuildNumberChange: Bool) -> Result<Project, CustomError>
    {
        var buildNumberIssueFiles = [String]()
        var versionNumberIssueFiles = [String]()
        
        for (index, target) in targets.enumerated() where target.selected && !target.isTestTarget
        {
            if isManualValue
            {
                if isBuildNumberChange
                {
                    targets[index].newBuildNumber = commonValue
                }
                else
                {
                    targets[index].newVersionNumber = commonValue
                    
                    if let builNumber = targets[index].newVersionNumber.getBuildNumberFromVersion(type: target.buildNumber.getBuildNumberType())
                    {
                        targets[index].newBuildNumber = builNumber
                    }
                    else
                    {
                        buildNumberIssueFiles.append(target.name)
                    }
                }
            }
            else if isBuildNumberChange
            {
                if let buildNumber = target.buildNumber.getIncreasedVersionNumber(for: incrementalValue, position: .last)
                {
                    targets[index].newBuildNumber = buildNumber
                }
                else
                {
                    versionNumberIssueFiles.append(target.name)
                }
                
            }
            else
            {
                if let versionNumber = target.versionNumber.getIncreasedVersionNumber(for: incrementalValue, position: postion)
                {
                    targets[index].newVersionNumber = versionNumber
                }
                else
                {
                    versionNumberIssueFiles.append(target.name)
                }
                
                if let builNumber = targets[index].newVersionNumber.getBuildNumberFromVersion(type: target.buildNumber.getBuildNumberType())
                {
                    targets[index].newBuildNumber = builNumber
                }
                else
                {
                    buildNumberIssueFiles.append(target.name)
                }
            }
        }
        
        if !buildNumberIssueFiles.isEmpty || !versionNumberIssueFiles.isEmpty
        {
            var errorString = "There is an issue in \(file.fileName.removeExtension) project"
            if !buildNumberIssueFiles.isEmpty
            {
                errorString += "\nBuild number generation error for file(s) - \(buildNumberIssueFiles.joined(separator: ","))"
            }
            if !versionNumberIssueFiles.isEmpty
            {
                errorString += "\nVersion number generation error for file(s) - \(versionNumberIssueFiles.joined(separator: ","))"
            }
            
            return .failure(CustomError(title: "Unable to Generate Number", description: errorString))
        }

        return .success(self)
    }
    
    func getNewSampleBuildNumber() -> String
    {
        for target in self.targets
        {
            if target.newBuildNumber != ""
            {
                return target.newBuildNumber
            }
        }
        
        return ""
    }
    
    func getNewSampleVersionNumber() -> String
    {
        for target in self.targets
        {
            if target.newVersionNumber != ""
            {
                return target.newVersionNumber
            }
        }
        
        return ""
    }
    
}

extension Array where Element == Project
{
    mutating func syncNumber(incrementValue: Int, postion: Postion, isBuild: Bool)
    {
        guard self.count > 1 else { return }
        
        var highestValue = 0
        
        if isBuild
        {
            self.forEach{
                let intValue = $0.sampleBuildNumber.getInt(in: postion) ?? 0
                if intValue > highestValue
                {
                    highestValue = intValue
                }
            }
        }
        else
        {
            self.forEach{
                let intValue = $0.sampleVersionNumber.getInt(in: postion) ?? 0
                if intValue > highestValue
                {
                    highestValue = intValue
                }
            }
        }
        
        highestValue = highestValue + incrementValue
        
        for (index, project) in self.enumerated()
        {
            if isBuild
            {
                self[index].incrementalValue = highestValue - (project.sampleBuildNumber.getInt(in: postion) ?? 0)
            }
            else
            {
                self[index].incrementalValue = highestValue - (project.sampleVersionNumber.getInt(in: postion) ?? 0)
            }
            
        }
    }
    
    func getNewSampleBuildNumber() -> String
    {
        for project in self
        {
            for target in project.targets
            {
                if target.newBuildNumber != ""
                {
                    return target.newBuildNumber
                }
            }
        }
        
        return ""
    }
    
    func getNewSampleVersionNumber() -> String
    {
        for project in self
        {
            for target in project.targets
            {
                if target.newVersionNumber != ""
                {
                    return target.newVersionNumber
                }
            }
        }
        
        return ""
    }
}

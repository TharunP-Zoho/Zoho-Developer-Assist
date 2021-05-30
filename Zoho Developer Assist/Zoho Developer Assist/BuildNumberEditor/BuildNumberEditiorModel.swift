//
//  BuildNumberEditiorModel.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 08/05/21.
//

import SwiftUI

struct CustomError: Error
{
    var title: String
    var description: String
}

extension Result
{
    func resultWithCustomError(errorTitle: String) -> Result<Success, CustomError>
    {
        switch self {
        case .success(let sucess):
            return .success(sucess)
        case .failure(let error):
            return .failure(CustomError(title: errorTitle, description: error.localizedDescription))
        }
    }
}

struct Project: Hashable
{
    var file = ""
    var targets = [Target]()
    var selected = false
    var isManualValue = false
    var commonValue = ""
    var sampleBuildNumber = ""
    var sampleVersionNumber = ""
    
    mutating func computeValue(incrementalValue: Int, postion: Postion, isBuildNumberChange: Bool) -> Result<Project, CustomError>
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
}

struct BuildConfig: Hashable
{
    var id = ""
    var name = ""
}

struct Target: Hashable
{
    var name = ""
    var buildConfig = [BuildConfig]()
    var buildNumber = ""
    var versionNumber = ""
    var newBuildNumber = ""
    var newVersionNumber = ""
    var selected = true
    var isTestTarget = false
    
}

enum Postion: Hashable
{
    case other(Int), last
    
    func getString() -> String
    {
        switch self
        {
        case .other(let integer):
            return "\(integer)"
        case .last:
            return "Last"
        }
    }
}

enum BuildNumberType
{
   case plain, combineLastTwoWithHunderMutiple
}


struct BuildNumberEditiorModel
{
    var workspaceUrl = ""
    var workspaceFormattedName = ""
    var projectList = [Project]()
    var fullProjectList = [""]
    var isSelectAllProject = false
    var isRemovePodAndFrameworkProject = false
    var isBuild = true
    var isNeedSync = false
    var incrementalValue = 1
    var isFullyManual = false
    var postions = [Postion.other(1), Postion.other(2), Postion.last]
    var selectedPosition = Postion.last
    var excutableProjects = [Project]()
    var isPreviouslyLoaded = false
    
    enum UserDefaultKeys: String
    {
        case workspaceUrl, workspaceFormattedName, isSelectAllProject, isRemovePodAndFrameworkProject
    }
    
    mutating func loadData()
    {
        let defaults: UserDefaults = .standard
       
        workspaceUrl = defaults.value(forKey: UserDefaultKeys.workspaceUrl.rawValue) as? String ?? ""
        workspaceFormattedName = defaults.value(forKey: UserDefaultKeys.workspaceFormattedName.rawValue) as? String ?? ""
        isSelectAllProject = defaults.value(forKey: UserDefaultKeys.isSelectAllProject.rawValue) as? Bool ?? false
        isRemovePodAndFrameworkProject = defaults.value(forKey: UserDefaultKeys.isRemovePodAndFrameworkProject.rawValue) as? Bool ?? false
        
        isPreviouslyLoaded = true
    }
    
    func saveData()
    {
        let defaults: UserDefaults = .standard
        
        defaults.setValue(workspaceUrl, forKey: UserDefaultKeys.workspaceUrl.rawValue)
        defaults.setValue(workspaceFormattedName, forKey: UserDefaultKeys.workspaceFormattedName.rawValue)
        defaults.setValue(isSelectAllProject, forKey: UserDefaultKeys.isSelectAllProject.rawValue)
        defaults.setValue(isRemovePodAndFrameworkProject, forKey: UserDefaultKeys.isRemovePodAndFrameworkProject.rawValue)
    }

    
}

//
//  BuildNumberEditiorModel.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 08/05/21.
//

import SwiftUI

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
    
    //Git
    var isGitNeeded = false
    var gitLocation = ""
    var needToCreateNewBranch = false
    var newBranchName = ""
    var commitMsg = ""
    var needToRaiseMR = false
    var targetBranch = ""
    var branchList = [""]
    var mrTitle = ""
    var mrDescription = ""
    var mrAssign = ""
    
    //MARK: Save and load Data
    
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

    //MARK: Git Strings
    
    func getMRTitle() -> String
    {
        return "Changed \(isBuild ? "Build" : "Version") number to \(isBuild ? excutableProjects.getNewSampleBuildNumber() : excutableProjects.getNewSampleVersionNumber())"
    }
    
    func getMRDescription() -> String
    {
        var result = "Changed the \(isBuild ? "Build" : "Version") number:\n"
        
        if isBuild
        {
            for project in excutableProjects
            {
                result += "\(project.file.fileName.removeExtension) : \(project.sampleBuildNumber) -> \(project.getNewSampleBuildNumber())\n"
            }
        }
        else
        {
            for project in excutableProjects
            {
                result += "\(project.file.fileName.removeExtension) : \(project.sampleVersionNumber) -> \(project.getNewSampleVersionNumber())\n"
            }
        }
        
        result += "\nComments\n\(commitMsg)\n\n\nNote: This MR and the changes is raised from Zoho Developer Assist - Internal App"
        
        
        return result
    }
    
    func getCommitMsg() -> String
    {
        return "Changed the \(isBuild ? "Build" : "Version") number for \((excutableProjects.compactMap{ $0.file.fileName.removeExtension }).joined(separator: ", ")) #Zoho-Developer-Assist"
    }
    
}


//
//  BuildNumberEditiorModel.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 08/05/21.
//

import SwiftUI

struct Project: Hashable
{
    var file = ""
    var targets = [Target]()
    var selected = false
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
    var needToAvoid = false
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
    var postions = [Postion.other(1), Postion.other(2), Postion.last]
    var selectedPosition = Postion.last
    var excutableProjects = [Project]()
    
    enum UserDefaultKeys: String
    {
        case workspaceUrl, workspaceFormattedName, projectList, selectedProjectList, isSelectAllProject, isRemovePodAndFrameworkProject
    }
    
    mutating func loadData()
    {
        let defaults: UserDefaults = .standard
       
//        workspaceUrl = defaults.value(forKey: UserDefaultKeys.workspaceUrl.rawValue) as? String ?? ""
//        workspaceFormattedName = defaults.value(forKey: UserDefaultKeys.workspaceFormattedName.rawValue) as? String ?? ""
//        projectList = defaults.value(forKey: UserDefaultKeys.projectList.rawValue) as? [String] ?? [""]
//        selectedProjectList = defaults.value(forKey: UserDefaultKeys.selectedProjectList.rawValue) as? [String] ?? [""]
//        isSelectAllProject = defaults.value(forKey: UserDefaultKeys.isSelectAllProject.rawValue) as? Bool ?? false
//        isRemovePodAndFrameworkProject = defaults.value(forKey: UserDefaultKeys.isRemovePodAndFrameworkProject.rawValue) as? Bool ?? false
    }
    
    func saveData()
    {
        saveJson()
        let defaults: UserDefaults = .standard
        
//        defaults.setValue(workspaceUrl, forKey: UserDefaultKeys.workspaceUrl.rawValue)
//        defaults.setValue(workspaceFormattedName, forKey: UserDefaultKeys.workspaceFormattedName.rawValue)
//        defaults.setValue(projectList, forKey: UserDefaultKeys.projectList.rawValue)
//        defaults.setValue(selectedProjectList, forKey: UserDefaultKeys.selectedProjectList.rawValue)
//        defaults.setValue(isSelectAllProject, forKey: UserDefaultKeys.isSelectAllProject.rawValue)
//        defaults.setValue(isRemovePodAndFrameworkProject, forKey: UserDefaultKeys.isRemovePodAndFrameworkProject.rawValue)
    }
//

    func saveJson()
    {
        let json = "Hai THarun"

        try! json.write(to: URL(fileURLWithPath: "/Users/tharun-pt3265/zohofinance_ios/testApp.Json"), atomically: true, encoding: String.Encoding.utf8)
    }
    
}

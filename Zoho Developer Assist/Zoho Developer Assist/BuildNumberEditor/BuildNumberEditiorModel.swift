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
    var isManualValue = false
    var commonValue = ""
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
    var manualNumber = ""
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

struct EnumeratedForEach<ItemType, ID , ContentView: View>: View {
    let data: [ItemType]
    let content: (Int, ItemType) -> ContentView
    let id: KeyPath<Data.Element, ID>
    
    init(_ data: [ItemType], id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Int, ItemType) -> ContentView) {
        self.data = data
        self.content = content
        self.id = id
    }
    
    var body: some View {
        ForEach(Array(self.data.enumerated()), id: \.offset) { idx, item in
            self.content(idx, item)
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

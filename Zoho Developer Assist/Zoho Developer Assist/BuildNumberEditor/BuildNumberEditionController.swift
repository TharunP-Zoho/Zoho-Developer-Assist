//
//  BuildNumberEditionController.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 08/05/21.
//

import Foundation

struct BuildNumberEditiorController
{
    var model = BuildNumberEditiorModel()
    
    init()
    {
        model.loadData()
    }
    
    
    func searchProjectList(complationHandler: @escaping ([String],[Project]) -> Void)
    {
        let safeModel = model
        let safeSelf = self
        
        DispatchQueue.global(qos: .userInitiated).async
        {
            
            let tempFullProjectList  = FileManager.default.getAllFilesRecursively(url: URL(fileURLWithPath: safeModel.workspaceUrl))
                .filter{ path in path.pathExtension == FileParser.FileExtension.xcodeproj.rawValue }
                .compactMap(){ url in url.string }
            
            let tempProjectList = safeSelf.getProjectList(fullProjectList: tempFullProjectList, projectList: safeModel.projectList, isSelectAllProject: safeModel.isSelectAllProject, isRemovePodAndFrameworkProject: safeModel.isRemovePodAndFrameworkProject)
            
            DispatchQueue.main.async
            {
                complationHandler(tempFullProjectList, tempProjectList)
            }
        }

    }
    
    func getProjectList(fullProjectList: [String], projectList: [Project], isSelectAllProject: Bool, isRemovePodAndFrameworkProject: Bool, isTakeValueFromOld: Bool = true) -> [Project]
    {
        func getSelectedValueForFileFromProjectList(projectList: [Project], fileName: String) -> Bool
        {
            var value = false
            projectList.forEach() { project in
                if project.file == fileName
                {
                    value = project.selected
                    return
                }
            }
    
            return value
        }
        
        var tempProjectList = [Project]()
        
        fullProjectList.forEach(){ projectFile in
            
            if (!((projectFile.fileName.removeExtension.lowercased().contains("kit") || projectFile.fileName.removeExtension.lowercased().contains("pod")) && isRemovePodAndFrameworkProject))
            {
                tempProjectList.append(Project(file: projectFile, selected: isSelectAllProject ? true : (isTakeValueFromOld ? getSelectedValueForFileFromProjectList(projectList: projectList, fileName: projectFile) : false)))
            }
        }
        
        return tempProjectList
    }
    
    
}

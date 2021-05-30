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
    
    
    func searchProjectList(complationHandler: @escaping (Result<([String],[Project]), CustomError>) -> Void)
    {
        let safeModel = model
        let safeSelf = self
        
        DispatchQueue.global(qos: .userInitiated).async
        {
            
            let tempFullProjectList  = FileManager.default.getAllFilesRecursively(url: URL(fileURLWithPath: safeModel.workspaceUrl))
                .filter{ path in path.pathExtension == FileParser.FileExtension.xcodeproj.rawValue }
                .compactMap(){ url in url.string }
            
            let tempProjectList = safeSelf.getProjectList(fullProjectList: tempFullProjectList, projectList: safeModel.projectList, isSelectAllProject: safeModel.isSelectAllProject, isRemovePodAndFrameworkProject: safeModel.isRemovePodAndFrameworkProject){error in
                DispatchQueue.main.async
                {
                    complationHandler(.failure(error))
                }}
            
            DispatchQueue.main.async
            {
                if tempFullProjectList.isEmpty && tempProjectList.isEmpty
                {
                    complationHandler(.failure(CustomError(title: "No Projects Found", description: "There is no project file found in the selected workspace")))
                }
                else
                {
                    complationHandler(.success((tempFullProjectList, tempProjectList)))
                }
            }
        }

    }
    
    func getProjectList(fullProjectList: [String], projectList: [Project], isSelectAllProject: Bool, isRemovePodAndFrameworkProject: Bool, isTakeValueFromOld: Bool = true, errorHandler: (CustomError) -> Void) -> [Project]
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
        
        func getSampleVersionAndBuildNumber(for projectFile: String) -> (version: String, build: String)
        {
            let projectFileString = FileManager.default.readFile(url: projectFile + "/project.pbxproj", errorHandler: errorHandler)
            
            var versionNumber = Regex.matches(for: "MARKETING_VERSION = ([0-9]+(.[0-9]+)+)", soruce: projectFileString).first ?? "THarun"
            versionNumber = versionNumber.replacingOccurrences(of: "MARKETING_VERSION = ", with: "")
            
            var buildNumber = Regex.matches(for: "CURRENT_PROJECT_VERSION = ([0-9]+(.[0-9]+)+)", soruce: projectFileString).first ?? "Tharun"
            buildNumber = buildNumber.replacingOccurrences(of: "CURRENT_PROJECT_VERSION = ", with: "")
            
            return (versionNumber, buildNumber)
            
        }
        
        var tempProjectList = [Project]()
        
        fullProjectList.forEach(){ projectFile in
            
            if (!((projectFile.fileName.removeExtension.lowercased().contains("kit") || projectFile.fileName.removeExtension.lowercased().contains("pod")) && isRemovePodAndFrameworkProject))
            {
                let sample = getSampleVersionAndBuildNumber(for: projectFile)
                
                tempProjectList.append(Project(file: projectFile, selected: isSelectAllProject ? true : (isTakeValueFromOld ? getSelectedValueForFileFromProjectList(projectList: projectList, fileName: projectFile) : false), sampleBuildNumber: sample.build, sampleVersionNumber: sample.version))
            }
        }
        
        return tempProjectList
    }
    
    
    func getExcutableProjects(projectList: [Project], complationHandler: @escaping (Result<[Project], CustomError>) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            var excutableProjects = [Project]()
            
            projectList.forEach() { project in
                
                if project.selected
                {
                    excutableProjects.append(Project(file: project.file, targets: getTargetsForProject(project){ error in
                        complationHandler(Result.failure(error))
                    }, selected: project.selected))
                }
                
            }
            
            DispatchQueue.main.async
            {
                complationHandler(Result.success(excutableProjects))
            }
        }
        
    }
    
    func getTargetsForProject(_ project: Project, errorHandler: (CustomError) -> Void) -> [Target]
    {
        var resultTargets = [Target]()
        
        let projectFile = FileManager.default.readFile(url: project.file + "/project.pbxproj", errorHandler: errorHandler)
        
        if projectFile == ""
        {
            return []
        }
        
        let XCConfigurationListSection = projectFile.getSectionInProjectFile(sectionName: "XCConfigurationList")
        
        var XCConfigurationListRows = XCConfigurationListSection.components(separatedBy: "Build configuration list")
        XCConfigurationListRows.remove(at: 0)
        
        for (_, row) in XCConfigurationListRows.enumerated()
        {
            let name = row.slice(from: "\"", to: "\"") ?? ""
            let isPBXProject = row.contains("PBXProject")
            
            if !isPBXProject
            {
                var tempTarget  = Target(name: name)
                let lines = row.components(separatedBy: "\n")
                
                lines.forEach() { line in
                    if line.contains("/*")
                    {
                        var tempBuild = BuildConfig()
                        let tempLine = line.trimmingCharacters(in: .whitespaces)
                        let sets = tempLine.components(separatedBy: " /*")
                        
                        if sets.count >= 2
                        {
                            tempBuild.id = sets[0]
                            tempBuild.name = line.slice(from: "/* ", to: " */") ?? ""
                            
                            if !tempBuild.name.isEmpty
                            {
                                tempTarget.buildConfig.append(tempBuild)
                            }
                        }
                        
                    }
                }
                
                resultTargets.append(tempTarget)
            }
        }
        
        // Setting values
        
        let XCBuildConfigurationSection = projectFile.getSectionInProjectFile(sectionName: "XCBuildConfiguration")
        
        for (index, resultTarget) in resultTargets.enumerated()
        {
            let tempBreakString = XCBuildConfigurationSection.components(separatedBy: resultTarget.buildConfig[0].id).last ?? ""
            
            let XCBuildConfigurationRows = tempBreakString.components(separatedBy: "isa = XCBuildConfiguration;")
            let XCBuildConfigurationRow = XCBuildConfigurationRows[1]
            
            if XCBuildConfigurationRow.contains("TEST_TARGET_NAME") || XCBuildConfigurationRow.contains("TEST_HOST")
            {
                resultTargets[index].isTestTarget = true
            }
            
            resultTargets[index].versionNumber = XCBuildConfigurationRow.slice(from: "MARKETING_VERSION = ", to: ";") ?? ""
            resultTargets[index].buildNumber = XCBuildConfigurationRow.slice(from: "CURRENT_PROJECT_VERSION = ", to: ";") ?? ""
            
            if resultTargets[index].versionNumber.isEmpty || resultTargets[index].buildNumber.isEmpty
            {
                resultTargets[index].selected = false
            }
        }
        
        return resultTargets
    }
    
    func computeValue(for model: BuildNumberEditiorModel, completionHandler: @escaping (Result<BuildNumberEditiorModel, CustomError>) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            var resultModel = model
            
            for (index, project) in  resultModel.excutableProjects.enumerated()
            {
                var tempProject = project
                switch tempProject.computeValue(incrementalValue: model.incrementalValue, postion: model.selectedPosition, isBuildNumberChange: model.isBuild)
                {
                case .success(let newProject):
                    resultModel.excutableProjects[index] = newProject
                case .failure(let error):
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                }
            }
            
            DispatchQueue.main.async { completionHandler(.success(resultModel)) }
        }
    }
}

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
            
            let tempProjectList = safeSelf.getProjectList(fullProjectList: tempFullProjectList, projectList: safeModel.projectList){error in
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
    
    func getProjectList(fullProjectList: [String], projectList: [Project], errorHandler: (CustomError) -> Void) -> [Project]
    {
        
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
            
            let sample = getSampleVersionAndBuildNumber(for: projectFile)
            
            tempProjectList.append(Project(file: projectFile, sampleBuildNumber: sample.build, sampleVersionNumber: sample.version))
            
        }
        
        return tempProjectList
    }
    
    
    func getExcutableProjects(projectList: [Project], complationHandler: @escaping (Result<[Project], CustomError>) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            var excutableProjects = [Project]()
            
            projectList.forEach() { project in
                
                if project.selected && !(model.isRemovePodAndFrameworkProject && project.isPodOrFrameWork())
                {
                    excutableProjects.append(Project(file: project.file, targets: self.getTargetsForProject(project){ error in
                        complationHandler(Result.failure(error))
                    }, selected: project.selected, isManualValue: model.isFullyManual, sampleBuildNumber: project.sampleBuildNumber, sampleVersionNumber: project.sampleVersionNumber))
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
    
    func searchGitFile(completionHandler: @escaping (Result<String, CustomError>) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            var tempUrl = "/"
            
            let folders = self.model.workspaceUrl.components(separatedBy: "/")
            
            for folder in folders where !folder.isEmpty
            {
                tempUrl += "\(folder)/"
                let files = FileManager.default.getFiles(url: tempUrl)
                
                if let strongFiles = files, strongFiles.contains(".git")
                {
                    DispatchQueue.main.async
                    {
                        completionHandler(.success(folder))
                    }
                }
                
            }
            
            DispatchQueue.main.async
            {
                completionHandler(.failure(CustomError(title: "Unable to find git file", description: "There is not git file in the selected localtion")))
            }
        }
    }
    
    func fetchBrachList(needMore: Bool = false, completionHandler: @escaping (Result<[String], CustomError>) -> Void )
    {
        DispatchQueue.global(qos: .userInitiated).async
        {
            let git = Git(repoLocation: self.model.workspaceUrl.getUrlForFolder(self.model.gitLocation))
            
            let result = git.brachList(needMore: needMore)
            
            DispatchQueue.main.async
            {
                completionHandler(result)
            }
        }
    }
    
    func save(progessHandler: @escaping (Int) -> Void, completionHandler: @escaping (Result<String, CustomError>) -> Void)
    {
        func sendResult(_ result: Result<String, CustomError>) -> Bool
        {
            switch result
            {
            case .failure(let error):
                DispatchQueue.main.async
                {
                    completionHandler(.failure(error))
                }
                return false
            case .success(_):
                DispatchQueue.main.async
                {
                    progessHandler(progressCount)
                    progressCount += 1
                }
                return true
            }
        }
        
        var progressCount = 0
        var canProceed = true
        
        guard model.excutableProjects.count > 0 else {  completionHandler(Result.failure(CustomError(title: "Nothing Seleted", description: "")))
            return}
            
        //First Time
        progessHandler(progressCount)
        progressCount += 1
        
        //Saving
        model.saveData()
        
        DispatchQueue.global(qos: .userInitiated).async
        {

            let git = Git(repoLocation: self.model.workspaceUrl.getUrlForFolder(self.model.gitLocation))
            
            //Git Check status
            if canProceed && self.model.isGitNeeded
            {
                let result = git.statusCheck()
                canProceed = sendResult(result)
            }
            
            //Git New Branch
            if canProceed && self.model.needToCreateNewBranch
            {
                let result = git.newBranch(branchName: self.model.isBuild ? self.model.excutableProjects.getNewSampleBuildNumber() : self.model.excutableProjects.getNewSampleVersionNumber())
                canProceed = sendResult(result)
            }
            
            //Writing Project
            if canProceed
            {
                for project in self.model.excutableProjects
                {
                    self.writeProject(forProject: project){ result in
                        canProceed = sendResult(result)
                    }
                    
                    if !canProceed
                    {
                        break
                    }
                }
            }
            
            //Git commit adn push
            if canProceed && self.model.isGitNeeded
            {
                let result = git.commitAndPush(msg: self.model.getCommitMsg())
                canProceed = sendResult(result)
            }
            
            //Git raise MR
            if canProceed && self.model.needToRaiseMR
            {
                
            }
            
            //SuccessfullCompeleted
            if canProceed
            {
                DispatchQueue.main.async
                {
                    progessHandler(progressCount)
                    completionHandler(Result.success(""))
                }
            }
        }
    }
    
    func getProgressList() -> [ProgressItem]
    {
        var progressList = [ProgressItem]()
        
        //Git Check status
        if model.isGitNeeded
        {
            progressList.append(ProgressItem(itemName: "Checking Git status", state: .processing))
        }
        
        //Git New Branch
        if model.needToCreateNewBranch
        {
            progressList.append(ProgressItem(itemName: "Creating New Branch", state: .processing))
        }
        
        //Writing Project
        for project in self.model.excutableProjects
        {
            progressList.append(ProgressItem(itemName: "Writing Project File - \(project.file.fileName.removeExtension)", state: .processing))
        }
        
        //Git commit adn push
        if model.isGitNeeded
        {
            progressList.append(ProgressItem(itemName: "Committing and Pushing the changes", state: .processing))
        }
        
        //Git raise MR
        if model.needToRaiseMR
        {
            progressList.append(ProgressItem(itemName: "Raising Merge Request", state: .processing))
        }
        
        
        return progressList
    }
    
    private func writeProject(forProject project: Project, completionHandler: @escaping (Result<String, CustomError>) -> Void)
    {
        var projectFile = FileManager.default.readFile(url: project.file + "/project.pbxproj"){ error in completionHandler(.failure(error))}
        
        guard projectFile != "" else { completionHandler(.failure(CustomError(title: "Project File is Empty", description: "Unable to fetch the project file - \(project.file.fileName.removeExtension)"))); return }
        
        
        var XCBuildConfigurationSection = projectFile.getSectionInProjectFile(sectionName: "XCBuildConfiguration")
        
        for (_, target) in project.targets.enumerated() where target.selected
        {
            for buildConfig in target.buildConfig
            {
                var sectionIntoToTwo = XCBuildConfigurationSection.components(separatedBy: buildConfig.id)
                
                if sectionIntoToTwo.count < 2
                {
                    completionHandler(.failure(CustomError(title: "Unable to Parse", description: "Issue in parsing the project file - \(project.file.fileName.removeExtension)")))
                    return
                }
                
                var secondPartOfTheSection = sectionIntoToTwo[1]
                var XCBuildConfigurationRows = secondPartOfTheSection.components(separatedBy: "isa = XCBuildConfiguration;")
                
                if XCBuildConfigurationRows.count < 2
                {
                    completionHandler(.failure(CustomError(title: "Unable to Parse", description: "Issue in parsing the project file - \(project.file.fileName.removeExtension)")))
                    return
                }
                
                var XCBuildConfigurationRow = XCBuildConfigurationRows[1]
                
                if !(XCBuildConfigurationRow.contains("MARKETING_VERSION") && XCBuildConfigurationRow.contains("CURRENT_PROJECT_VERSION"))
                {
                    completionHandler(.failure(CustomError(title: "Unable to find version changes", description: "May be the version changes is first time for \(project.file.fileName.removeExtension) - \(target.name). So please try in Xcode for first time.")))
                    return
                }
                
                if model.isBuild
                {
                    XCBuildConfigurationRow = XCBuildConfigurationRow.replacingOccurrences(of: "CURRENT_PROJECT_VERSION = \(target.buildNumber);", with: "CURRENT_PROJECT_VERSION = \(target.newBuildNumber);")
                }
                else
                {
                    XCBuildConfigurationRow = XCBuildConfigurationRow.replacingOccurrences(of: "CURRENT_PROJECT_VERSION = \(target.buildNumber);", with: "CURRENT_PROJECT_VERSION = \(target.newBuildNumber);")
                    XCBuildConfigurationRow = XCBuildConfigurationRow.replacingOccurrences(of: "MARKETING_VERSION = \(target.versionNumber);", with: "MARKETING_VERSION = \(target.newVersionNumber);")
                }
                
                XCBuildConfigurationRows[1] = XCBuildConfigurationRow
                secondPartOfTheSection = XCBuildConfigurationRows.joined(separator: "isa = XCBuildConfiguration;")
                sectionIntoToTwo[1] = secondPartOfTheSection
                XCBuildConfigurationSection = sectionIntoToTwo.joined(separator: buildConfig.id)
                
                projectFile.setSectionInProjectFile(sectionName: "XCBuildConfiguration", value: XCBuildConfigurationSection)
            }
        }
        
        do
        {
            try projectFile.write(to: URL(fileURLWithPath: project.file + "/project.pbxproj"), atomically: true, encoding: .utf8)
        }
        catch
        {
            completionHandler(.failure(CustomError(title: "Unable to Write Project - \(project.file.fileName.removeExtension)", description: error.localizedDescription)))
        }
        
        completionHandler(.success(""))
    }
    
    //MARK: Compute
    
    func computeValue(for model: BuildNumberEditiorModel, completionHandler: @escaping (Result<BuildNumberEditiorModel, CustomError>) -> Void)
    {     let strTerminalPath = "/Users/tharun-pt3265/zohofinance_ios/"
        
        let git = Git(repoLocation: strTerminalPath)
        print(git.cmd("add --all").result)
        
        DispatchQueue.global(qos: .userInitiated).async
        {
            var resultModel = model
            
            if model.isNeedSync
            {
                resultModel.excutableProjects.syncNumber(incrementValue: model.incrementalValue, postion: model.selectedPosition, isBuild: model.isBuild)
            }
            else
            {
                for (index, _) in model.excutableProjects.enumerated()
                {
                    resultModel.excutableProjects[index].incrementalValue = model.incrementalValue
                }
            }
            
            for (index, project) in  resultModel.excutableProjects.enumerated()
            {
                var tempProject = project
                switch tempProject.computeValue(postion: model.selectedPosition, isBuildNumberChange: model.isBuild)
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

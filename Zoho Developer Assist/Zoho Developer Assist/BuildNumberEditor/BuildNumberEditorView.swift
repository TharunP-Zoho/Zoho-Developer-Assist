//
//  BuildNumberEditorView.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

struct BuildNumberEditorView: View {
    
    var backHandler: () -> Void
    
    @State var controller = BuildNumberEditiorController()
    
    @State var openFileImport = false
    @State var isAlertNeeded = false
    @State var alertTitle = ""
    @State var alertMsg = ""
    @State var isProgressViewNeeded = false
    @State var isPreviewReady = false
    @State var isSaving = false
    @State var isconstructingPreivew = false
    @State var isFirstLoad = true
    
    //progressHandling
    @State var progressStatus: Float = 0.0
    @State var currentProgressName = ""
    @State var progressList = [ProgressItem]()
    @State var needToShowProgressDetails = false
    
    //GitAlert
    @State var isGitAlertNeeded = true
    
    var body: some View {
        
            contentView()
    }
    
    private func viewDidLoad()
    {
        isProgressViewNeeded = controller.model.isPreviouslyLoaded
    }
    
    private func contentView() -> some View
    {
        VStack{
            
        if !isPreviewReady && !isSaving // Configuration View
        {
            VStack(alignment: .leading)
            {
                ScrollView(showsIndicators: false)
                {
                    configurationView()
                        .onAppear(perform: { self.viewDidLoad() })
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                
                getNavigationBar()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        }
        else if isPreviewReady && !isSaving // Preview View
        {
            VStack(alignment: .leading)
            {
                ScrollView(showsIndicators: false)
                {
                    getPreviewBanner()
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    getPreview()
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                
                getPreviewNavigationBar()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            .transition(AnyTransition.slide.combined(with: .opacity))
            .animation(.default)
            
        }
        else if isSaving // Saving View
        {
            getSavingView()
        }
        
        //Hack to show alert on async process
        if isAlertNeeded
        {
            Text("Error")
                .frame(width: 0.0001, height: 0.0001, alignment: .leading)
                .alert(isPresented: $isAlertNeeded, content: showAlert)
                
        }
            
        }
    }
    
    
    private func configurationView() -> some View
    {
        
        VStack(alignment: .leading, spacing: 15)
        {
            getWorkspaceInfo()
            
            Divider()
            
            if !controller.model.projectList.isEmpty
            {
                projectSelectionView()
                Divider()
                
                getBuilNumberSettings()
                Divider()
                
                getGitSettings()
                Divider()
                
            }
            
            if isProgressViewNeeded
            {
                HStack(alignment: .center)
                {
                    Spacer()
                    ProgressView()
                    Spacer()
                }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            }

        }
    }
    
    
    //MARK: WorkSpace
    private func getWorkspaceInfo() -> some View
    {
        if isFirstLoad
        {
            if !controller.model.workspaceFormattedName.isEmpty
            {
                controller.searchProjectList() { result in
                    
                    switch result
                    {
                    case .success(let (fullList, projectList)):
                        controller.model.fullProjectList = fullList
                        controller.model.projectList = projectList
                        isProgressViewNeeded = false
                        
                    case .failure(let error):
                        alertTitle = error.title
                        alertMsg = error.description
                        isAlertNeeded = true
                    }
                }
            }
        }
        
        return HStack{
            Text("Workspace :")
                .bold()
            
            if controller.model.workspaceUrl.isEmpty
            {
                Button("Choose the Workspace", action: { openFileImport = true })
                    .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.folder]){ result in
                        fileSelected(result.resultWithCustomError(errorTitle: "Invalid File Path"))
                    }.alert(isPresented: $isAlertNeeded, content: {
                        showAlert()
                    })
            }
            else
            {
                Text(controller.model.workspaceFormattedName)
                Button("Change", action: { openFileImport = true })
                    .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.folder]){ result in
                        fileSelected(result.resultWithCustomError(errorTitle: "Invalid File Path"))
                    }.alert(isPresented: $isAlertNeeded, content: {
                        showAlert()
                    })
            }
        }
    }
    
    private func fileSelected(_ result:  Result<URL, CustomError>)
    {
        switch result {
        
        case .success(let url):
            controller.model.workspaceUrl = url.string
            controller.model.workspaceFormattedName =  controller.model.workspaceUrl.fileName
            isProgressViewNeeded = true
            controller.searchProjectList() { result in
                
                switch result
                {
                case .success(let (fullList, projectList)):
                    controller.model.fullProjectList = fullList
                    controller.model.projectList = projectList
                    isProgressViewNeeded = false
                
                case .failure(let error):
                    alertTitle = error.title
                    alertMsg = error.description
                    isAlertNeeded = true
                
                }
            }
            
        case .failure(let error):
            alertTitle = error.title
            alertMsg = error.description
            isAlertNeeded = true
            
        }
    }
    
    private func showAlert() -> Alert
    {
        Alert(title: Text(alertTitle), message: Text(alertMsg), dismissButton: .cancel({
            if isSaving
            {
                isSaving = false
            }
        }))
    }
    
    
    //MARK: Project Selection
    
    private func projectSelectionView() -> some View
    {
        VStack(alignment: .leading, spacing: nil){
            
            HStack
            {
                
                Text("Select the Projects :")
                    .bold()
                
                Spacer()
                
                MultipleSelectionRow(title: controller.model.isSelectAllProject ? "Unselect All" : "Select All", isSelected: controller.model.isSelectAllProject)
                {
                    controller.model.isSelectAllProject.toggle()
                    controller.model.projectList = controller.getProjectList(fullProjectList: controller.model.fullProjectList,
                                                                             projectList: controller.model.projectList,
                                                                             isSelectAllProject: controller.model.isSelectAllProject,
                                                                             isRemovePodAndFrameworkProject: controller.model.isRemovePodAndFrameworkProject,
                                                                             isTakeValueFromOld: false, errorHandler: {_ in})
                    
                }
                
                Spacer()
                
                MultipleSelectionRow(title: "Remove Pods/Framework Projects", isSelected: controller.model.isRemovePodAndFrameworkProject)
                {
                    controller.model.isRemovePodAndFrameworkProject.toggle()
                    controller.model.projectList = controller.getProjectList(fullProjectList: controller.model.fullProjectList,
                                                                             projectList: controller.model.projectList,
                                                                             isSelectAllProject: controller.model.isSelectAllProject,
                                                                             isRemovePodAndFrameworkProject: controller.model.isRemovePodAndFrameworkProject, errorHandler: {_ in})
                    
                    
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                
            }
            
            
            VStack(alignment: .leading, spacing: nil)
            {
                
                ForEach(controller.model.projectList, id: \.self) { item in
                    
                    MultipleSelectionRow(title: item.file.fileName.removeExtension, isSelected: item.selected) {
                        
                        for (index, project) in controller.model.projectList.enumerated() where project == item
                        {
                            controller.model.projectList[index].selected.toggle()
                        }
                        
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
    
    //MARK:  Build Number Settings
    
    private func getBuilNumberSettings() -> some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            Text("Configuration :")
                .bold()
            
            Picker("Method :", selection: $controller.model.isFullyManual, content: {
                    Text("Auto").tag(false)
                    Text("Manual").tag(true)
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 120, height: nil, alignment: .leading)
           
            Picker("Type :", selection: $controller.model.isBuild, content: {
                            Text("Version").tag(false)
                            Text("Build").tag(true)
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300, height: nil, alignment: .leading)
            
            if !controller.model.isFullyManual
            {
                getBuilNumberChnage()
            }
        }
        
    }
    
    private func getBuilNumberChnage() -> some View
    {
        HStack
        {
            Text("Value :")
            
            Image(systemName: "arrowtriangle.left.fill").onTapGesture { controller.model.incrementalValue -= 1 }
            
            Text("\(controller.model.incrementalValue)")
            
            Image(systemName: "arrowtriangle.right.fill").onTapGesture { controller.model.incrementalValue += 1 }
            
            if !controller.model.isBuild
            {
                Picker("Position :", selection: $controller.model.selectedPosition) {
                    ForEach(controller.model.postions, id: \.self) { (index: Postion) in
                        Text(index.getString())
                    }
                }
                .frame(width: 200, height: nil, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            }
            
            Toggle("Need Sync", isOn: $controller.model.isNeedSync)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            
        }
    }
    
    //MARK: Git Settings
    
    private func getGitSettings() -> some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            Toggle("Git", isOn: $controller.model.isGitNeeded)
            
            if controller.model.isGitNeeded
            {
                if isGitAlertNeeded
                {
                    HStack(spacing: 5) {
                        Image(systemName: "info.circle.fill")
                            .font(.body)
                            .foregroundColor(.white)
                            
                        Text("Please Make Sure, your current branch has no uncommitted changes.")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Got it", action: {isGitAlertNeeded = false})
                            
                    }
                    .padding()
                    .background(Color.orange)
                    .onAppear(){ DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { isGitAlertNeeded = false }) }
                    .transition(AnyTransition.slide.combined(with: .opacity))
                    .animation(.easeOut)
                }
                
                
                Picker("Git Location :", selection: $controller.model.gitLocation, content: {
                    ForEach(controller.model.workspaceUrl.getFolderList(), id: \.self) { folder in
                        Text(folder)
                    }
                })
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("Creat New branch and do this change", isOn: $controller.model.needToCreateNewBranch)
                
                Toggle("Raise Merge Request", isOn: $controller.model.needToRaiseMR)
                
                if controller.model.needToRaiseMR
                {
                    VStack(alignment: .leading)
                    {
                        Text("Title : Auto Generate")
                            .foregroundColor(.gray)
                            .frame(height: 30)
                        Text("Description : Auto Generate (If need to add any point use \"Comments\"")
                            .foregroundColor(.gray)
                            .frame(height: 30)
                        
                        HStack{
                            Text("Assignee : ")
                                .frame(width: 70, height: 30, alignment: .leading)
                            TextField("", text: $controller.model.mrAssign)
                                .frame(width: 120, height: 30)
                            
                        }
                        HStack{
                            Text("Label : ")
                                .frame(width: 70, height: 30, alignment: .leading)
                            TextField("", text: $controller.model.mrLabel)
                                .frame(width: 120, height: 30)
                            
                        }
                        HStack{
                            Text("Milestone : ")
                                .frame(width: 70, height: 30, alignment: .leading)
                            TextField("", text: $controller.model.mrMilestone)
                                .frame(width: 120, height: 30)
                        }
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                    
                    VStack(alignment: .leading)
                    {
                        HStack
                        {
                            Text("Comments")
                            Text("(This will be add to the MR Description)")
                            .foregroundColor(.gray)
                        }
                        TextEditor(text: $controller.model.commitMsg)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 70)
                    }
                }
                
            }
        }.animation(.default)
    }
    
    //MARK: Preview Banner
    
    private func getPreviewBanner() -> some View
    {
        HStack{
            Spacer()
            Text("Let's check the preview")
                .font(.title2)
                .bold()
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("PerviewBanner")))
        
    }
    
    private func constructPreivew(completionHandler: @escaping () -> Void)
    {
        controller.getExcutableProjects(projectList: controller.model.projectList) { result in
            
            switch result
            {
            case .success(let projects):
                controller.model.excutableProjects = projects
            case .failure(let error):
                alertTitle = error.title
                alertMsg = error.description
                isAlertNeeded = true
            }
            
            controller.computeValue(for: controller.model){ result in
                
                switch result
                {
                case .success(let newModel):
                    controller.model = newModel
                    completionHandler()
                case .failure(let error):
                    alertTitle = error.title
                    alertMsg = error.description
                    isAlertNeeded = true
                }
            }
        }
    }
    //MARK:  Preview
    
    private func getPreview() -> some View
    {
        
        EnumeratedForEach(controller.model.excutableProjects, id: \.self){ (projectIndex, project) in
            
            VStack
            {
                //Number
                Collapsible( label:
                                {
                                    HStack
                                    {
                                        Text(project.file.fileName.removeExtension)
                                        Spacer()
                                        Picker("", selection: $controller.model.excutableProjects[projectIndex].isManualValue)
                                        {
                                            Text("Auto").tag(false)
                                            Text("Manual").tag(true)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .frame(width: 100, height: nil, alignment: .leading)
                                        
                                        Text(controller.model.isBuild ? "Build : " : "Version : ")
                                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                            .layoutPriority(10)
                                        TextField(project.commonValue, text: $controller.model.excutableProjects[projectIndex].commonValue)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                            .frame(width: 75)
                                            .layoutPriority(10)
                                        
                                    }
                                })
                {
                    
                    VStack(alignment: .leading)
                    {
                        EnumeratedForEach(project.targets, id: \.self, content: { (targetIndex, target) in
                            
                            if target.isTestTarget
                            { EmptyView() }
                            else
                            {
                            
                                HStack
                                {
                                    Toggle("", isOn: $controller.model.excutableProjects[projectIndex].targets[targetIndex].selected)
                                    HStack {
                                        Text("\(target.name)")
                                        Spacer()
                                    }.frame(width: 300)
                                    
                                    if controller.model.excutableProjects[projectIndex].isManualValue
                                    {
                                        TextField("0.0", text: $controller.model.excutableProjects[projectIndex].commonValue).frame(width: 75)
                                    }
                                    else
                                    {
                                        Text(controller.model.isBuild ? target.newBuildNumber : target.newVersionNumber)
                                    }
                                    Spacer()
                                }
                                Divider()
                            }
                        })
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                        .frame(maxWidth: .infinity)
                    }
                    
                }.animation(.easeOut).transition(.slide).frame(maxWidth: .infinity)
            
                Divider()
            }
        }
    }
    
    //MARK: Saving view
    
    private func getSavingView() -> some View
    {
        VStack
        {
            ProgressBar(value: $progressStatus)
                .frame(width: 400, height: 10, alignment: .center)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 10, trailing: 0))
            HStack
            {
                if progressStatus == 1.0
                {
                    Image(systemName: "checkmark.circle")
                        .scaleEffect(1.5)
                        .foregroundColor(.green)
                }
                else
                {
                    ProgressView()
                        .scaleEffect(0.5)
                }
                Text(currentProgressName)
            }
            
            if progressStatus == 1.0
            {
                Button("Back to Home", action: { backHandler() })
                    .frame(width: nil, height: 40, alignment: .center)
                    
            }
            else if !needToShowProgressDetails
            {
                Button("Show more Details", action: { needToShowProgressDetails.toggle()})
                    .frame(width: nil, height: 40, alignment: .center)
            }
            
            if needToShowProgressDetails
            {
                ScrollView
                {
                    VStack(alignment: .leading, spacing: nil)
                    {
                        ForEach(progressList.indices, id: \.self) { index in
                            
                            HStack{
                                if progressList[index].state == .completed
                                {
                                    Image(systemName: "checkmark.circle")
                                        .scaleEffect(1.5)
                                        .foregroundColor(.green)
                                        .frame(width: 40, height: 40, alignment: .center)
                                }
                                if progressList[index].state == .failed
                                {
                                    Image(systemName: "xmark.circle")
                                        .scaleEffect(1.5)
                                        .foregroundColor(.red)
                                        .frame(width: 40, height: 40, alignment: .center)
                                }
                                if progressList[index].state == .processing
                                {
                                    ProgressView()
                                        .scaleEffect(0.5)
                                        .frame(width: 40, height: 40, alignment: .center)
                                }
                                Text(progressList[index].itemName)
                            }
                        }
                    }
                }
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                .padding(EdgeInsets(top: 10, leading: 5, bottom: 50, trailing: 5))
            }
        }
    }
    
    //MARK:  Navigation Bar
    
    private func getNavigationBar() -> some View
    {
        VStack
        {
            Rectangle()
                .stroke(Color.init(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)), lineWidth: 0.5)
                .frame(height: 0.5)
                
            
            HStack(alignment: .center, spacing: nil){
                Button("Back", action: { backHandler() })
                Spacer()
                Button(action: {
                    isconstructingPreivew = true
                    constructPreivew(){
                        isPreviewReady = true
                        isconstructingPreivew = false
                    }
                }, label: {
                    HStack{
                        if isconstructingPreivew
                        {
                            ProgressView()
                                .scaleEffect(0.5)
                        }
                        else
                        {
                            Text("Preview")
                        }
                    }
                })
            }
            .padding()
        }
    }
    
    private func getPreviewNavigationBar() -> some View
    {
        VStack
        {
            Rectangle()
                .stroke(Color.init(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)), lineWidth: 0.5)
                .frame(height: 0.5)
                
            HStack(alignment: .center, spacing: nil){
                Button("Back", action: { isPreviewReady = false })
                Button("Back to Home", action: { backHandler() }).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                Spacer()
                Button("Save", action: { save() })
            }
            .padding()
        }
    }
    
    private func save()
    {
        isSaving = true
        
        progressList = controller.getProgressList()
        
        controller.save(progessHandler: progessHandler, completionHandler: { result in
            switch result
            {
            case .success(_):
                progressList.markAllCompleted()
                completedSound()
                showLocalNotification(title: controller.model.isBuild ? "Build Number is changed successfully" : "Version Number is changed successfully", subtitle: "\(controller.model.workspaceFormattedName) -> \(controller.model.excutableProjects.compactMap{ $0.file.fileName.removeExtension}.joined(separator: ", "))")
                
            case .failure(let error):
                progressList.markOthersAsFailed()
                alertMsg = error.description
                alertTitle = error.title
                isAlertNeeded = true
            }
        })
    }
    
    private func progessHandler(progress: Int)
    {
        let totalItem = progressList.count
        
        currentProgressName = progressList[progress].itemName
        progressStatus = Float(progress)/Float(totalItem)
        if progressStatus == 1.0
        {
            currentProgressName = "Completed"
        }
        
        if progress > 0 && progressList.count > progress
        {
            progressList[progress - 1].state = .completed
        }
    }
        
}

struct MultipleSelectionRow: View {
    var title: String
    @State var isSelected: Bool
    @State var reference: Bool = true
    var action: () -> Void

    var body: some View {
        
        HStack{
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .foregroundColor(isSelected ? Color.blue : Color.secondary)
            
            Text(title)
        }
        .onTapGesture {
            action()
            isSelected.toggle()
            reference.toggle()
        }
    }
    
}


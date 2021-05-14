//
//  BuildNumberEditorView.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

struct BuildNumberEditorView: View {
    
    var backLink: Binding<Tool>
    
    @State var controller = BuildNumberEditiorController()
    
    @State var openFileImport = false
    @State var isFileImportAlert = false
    @State var fileImportAlertMsg = ""
    @State var isProgressViewNeeded = false
    @State var isPreviewReady = false
    var isFirstLoad = true
    
    
    var body: some View {
        
        Text("Build Number Changes")
            .bold()
            .font(.title3)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        
        VStack(alignment: .leading)
        {
            ScrollView(showsIndicators: false)
            {
                contentView()
                    .onAppear(perform: { self.viewDidLoad() })
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            getNavigationBar()
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
        
        
                
    }
    
    private func viewDidLoad()
    {
        isProgressViewNeeded = controller.model.isPreviouslyLoaded
    }
    
    private func contentView() -> some View
    {
        
        VStack(alignment: .leading, spacing: 15)
        {
            getWorkspaceInfo()
            
            Divider()
            
            if !controller.model.projectList.isEmpty
            {
                projectSelectionView()
                Divider()
                
                getBuilNumberChange()
                Divider()
                
                Spacer()
                if isPreviewReady
                {
                    getPreview()
                }
                else
                {
                    getPreviewButton()
                }
                
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
    
    
    // ----------------------------------- WorkSpace -----------------------
    private func getWorkspaceInfo() -> some View
    {
        if isFirstLoad
        {
            if !controller.model.workspaceFormattedName.isEmpty
            {
                controller.searchProjectList() { (fullList, projectList) in
                    controller.model.fullProjectList = fullList
                    controller.model.projectList = projectList
                    isProgressViewNeeded = false
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
                        fileSelected(result)
                    }.alert(isPresented: $isFileImportAlert, content: {
                        showFileImportAlert()
                    })
            }
            else
            {
                Text(controller.model.workspaceFormattedName)
                Button("Change", action: { openFileImport = true })
                    .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.folder]){ result in
                        fileSelected(result)
                    }.alert(isPresented: $isFileImportAlert, content: {
                        showFileImportAlert()
                    })
            }
        }
    }
    
    private func fileSelected(_ result:  Result<URL, Error>)
    {
        switch result {
        
        case .success(let url):
            controller.model.workspaceUrl = url.string
            controller.model.workspaceFormattedName =  controller.model.workspaceUrl.fileName
            isProgressViewNeeded = true
            controller.searchProjectList() { (fullList, projectList) in
                controller.model.fullProjectList = fullList
                controller.model.projectList = projectList
                isProgressViewNeeded = false
            }
            
        case .failure(let error):
            fileImportAlertMsg = error.localizedDescription
            isFileImportAlert = true
            
        }
    }
    
    private func showFileImportAlert() -> Alert
    {
        Alert(title: Text("File Path Error"), message: Text(fileImportAlertMsg), dismissButton: .cancel())
    }
    
    
    // ----------------------------------- Project Selection -----------------------
    
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
                                                                             isTakeValueFromOld: false)
                    
                }
                
                Spacer()
                
                MultipleSelectionRow(title: "Remove Pods/Framework Projects", isSelected: controller.model.isRemovePodAndFrameworkProject)
                {
                    controller.model.isRemovePodAndFrameworkProject.toggle()
                    controller.model.projectList = controller.getProjectList(fullProjectList: controller.model.fullProjectList,
                                                                             projectList: controller.model.projectList,
                                                                             isSelectAllProject: controller.model.isSelectAllProject,
                                                                             isRemovePodAndFrameworkProject: controller.model.isRemovePodAndFrameworkProject)
                    
                    
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
    
    // ----------------------------------- Build Number -----------------------
    
    private func getBuilNumberChange() -> some View
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
                            Text("Version").tag(true)
                            Text("Build").tag(false)
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300, height: nil, alignment: .leading)
            
            HStack
            {
                Text("Value :")
                
                Image(systemName: "arrowtriangle.left.fill").onTapGesture { controller.model.incrementalValue -= 1 }
                
                Text("\(controller.model.incrementalValue)")
                
                Image(systemName: "arrowtriangle.right.fill").onTapGesture { controller.model.incrementalValue += 1 }
                
                Picker("Position :", selection: $controller.model.selectedPosition) {
                    ForEach(controller.model.postions, id: \.self) { (index: Postion) in
                        Text(index.getString())
                    }
                }
                .frame(width: 200, height: nil, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                Toggle("Need Sync", isOn: $controller.model.isNeedSync)
                
            }
        }
    }
    
    // ----------------------------------- Preview Banner -----------------------
    
    private func getPreviewButton() -> some View
    {
        HStack{
            Text("Let's check in preview")
            Spacer()
            Button("Preview", action: {
                isProgressViewNeeded = true
                controller.getExcutableProjects(projectList: controller.model.projectList) { result in
                    
                    isProgressViewNeeded = false
                    
                    switch result
                    {
                    case .success(let projects):
                        controller.model.excutableProjects = projects
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                    
                    isPreviewReady = true
                }
            })
        }
        .padding()
        .background(Color("PerviewBanner"))
        
        
    }
    // ----------------------------------- Preview ------------------------------
    
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
                                        Text("\(target.buildNumber)")
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
    // ----------------------------------- Navigation Bar -----------------------
    
    private func getNavigationBar() -> some View
    {
        VStack
        {
            Rectangle()
                .stroke(Color.init(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)), lineWidth: 0.5)
                .frame(height: 0.5)
                
            
            HStack(alignment: .center, spacing: nil){
                Button("Back", action: { backLink.wrappedValue = .none })
                Spacer()
                Button("Save", action: { controller.model.saveData() })
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
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


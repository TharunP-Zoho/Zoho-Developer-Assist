//
//  LocalBuildTesterView.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/06/21.
//

import SwiftUI

struct LocalBuildTesterView: View
{
    @State var controller = LocalBuildTesterController()
    var backHandler: () -> Void
    
    @State var openFileImport = false
    @State var isAlertNeeded = false
    
    var string = ""
    
    var body: some View {
            contentView()
    }
    
    private func contentView() -> some View
    {
        VStack
        {
            Text("Work in Progress !")
                .font(.title)
                .padding()
            
            Button("Back to Home", action: { backHandler() })
                .frame(width: nil, height: 40, alignment: .center)
        }
    }
    
    private func getWorkspaceInfo() -> some View
    {
        
        return HStack{
            Text("Workspace :")
                .bold()
            
            if controller.model.workspaceUrl.isEmpty
            {
                Button("Choose the Workspace", action: { openFileImport = true })
                    .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.fileURL]){ result in
                        fileSelected(result.resultWithCustomError(errorTitle: "Invalid File Path"))
                    }.alert(isPresented: $isAlertNeeded, content: {
                        showAlert()
                    })
            }
            else
            {
                Text(controller.model.workspaceFormattedName)
                Button("Change", action: { openFileImport = true })
                    .fileImporter(isPresented: $openFileImport, allowedContentTypes: [.init(filenameExtension: "ZohoFinanceIOS.xcworkspace")!]){ result in
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
            controller.model.workspaceUrl = url.path
            test()
        default:
            break
        }
        
    }
    private func showAlert() -> Alert
    {
        Alert(title: Text("alertTitle"), message: Text("alertMsg"), dismissButton: .cancel())
    }
    
    private func test()
    {
        let git = XCodeBuild(repoLocation: "/Users/tharun-pt3265/")
        let s = git.cmd("list")
            print(s)
    }
}

struct LocalBuildTesterView_Previews: PreviewProvider {
    static var previews: some View {
        LocalBuildTesterView(backHandler: {})
    }
}

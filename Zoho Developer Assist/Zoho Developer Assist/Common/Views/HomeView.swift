//
//  ContentView.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

struct HomeView: View {
    
    let windowSize = WindowSize()
    
    @State private var showingSheet = false
    @State private var tool = Tool.none
    
    var body: some View {
        
        switch tool
        {
        case .none:
            getHomeView()
        case .buildNumberChanger:
            BuildNumberEditorView(backLink: $tool)
        }
        
        
    }

    private func getHomeView() -> some View
    {
        VStack{
            
            Image("AppIcons")
                .scaledToFit()
            
            Text("Zoho Developer Assist")
                .bold()
                .font(.largeTitle)
                .padding()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            
            HStack(spacing: 20){
                
                ToolView(id: .buildNumberChanger, title: "Build Number Changer", describtion: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.", icon: "building.columns", iconColor: "BuildIcon", iconBackground: "BuildIconBackground", selectedTool: $tool)
                    
                ToolView(id: .buildNumberChanger, title: "Build Number Changer", describtion: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.", icon: "building.columns", iconColor: "BuildIcon", iconBackground: "BuildIconBackground", selectedTool: $tool)
                
                ToolView(id: .buildNumberChanger, title: "Build Number Changer", describtion: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.", icon: "building.columns", iconColor: "BuildIcon", iconBackground: "BuildIconBackground", selectedTool: $tool)
                
            }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
    }
  
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

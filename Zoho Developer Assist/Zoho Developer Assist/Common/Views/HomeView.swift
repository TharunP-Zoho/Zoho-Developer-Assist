//
//  ContentView.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

struct HomeView: View {
    
    let windowSize = WindowSize()
    
    private var toolsList = ToolList()
    
    @State private var showingSheet = false
    @State private var selectedTool = Tool.none
    
    //Animation Property
    @State private var isTapped = false
    @State private var isTranstitonGoingOn = false
    @Namespace private var animation
    @State var isBackFromTool = false
    @State var isBackgroundScrolling = false
    
    var body: some View {
        
        ZStack{
            
            getBackgroundView()
        
            VStack{
                
                getTitleAnimation()
                
                if isTranstitonGoingOn
                {
                    self.toolsList.getViewForTool(selectedTool){ isTranstitonGoingOn = false; isBackFromTool = true }
                        .animation(.default)
                        .transition(.move(edge: .bottom))
                    
                }
                else
                {
                    getHomeView()
                }
             
            }
            
        }

        
    }

    private func getHomeView() -> some View
    {
            HStack(spacing: 20){
                
                ForEach(toolsList.tools, id: \.self) { tool in
                    
                    ToolView(id: tool.id, title: tool.title, describtion: tool.description, icon: tool.icon, iconColor: tool.iconColor, iconBackground: tool.iconBackground, selectedTool: $selectedTool, isTapped: $isTapped)
                }
        }
    }
    
    private func getTitleAnimation() -> some View
    {
        VStack{
        
        if !isTapped
        {
            VStack{
                
            Image("AppIcons")
                .frame(width: 100, height: 100)
                .matchedGeometryEffect(id: "Icon", in: animation)
            
            Text("Zoho Developer Assist")
                .bold()
                .font(.largeTitle)
                .padding()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
                .matchedGeometryEffect(id: "title", in: animation)
                
            }.matchedGeometryEffect(id: "stack", in: animation)
        }
        
        if isTapped && !isTranstitonGoingOn
        {
            let tool = toolsList.getTool(for: selectedTool)
            
            VStack{
                
            Image(systemName: tool.icon)
                .foregroundColor(Color(tool.iconColor))
                .frame(width: 100, height: 100)
                .scaleEffect(2)
                .background(
                    RoundedRectangle(cornerRadius: 50).fill(Color(tool.iconBackground))
                )
                .matchedGeometryEffect(id: "Icon", in: animation)
            
            Text(tool.title)
                .bold()
                .font(.largeTitle)
                .padding()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
                .matchedGeometryEffect(id: "title", in: animation)
            
            }
            .matchedGeometryEffect(id: "stack", in: animation)
            .onAppear(perform: {
                if !isBackFromTool
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isTranstitonGoingOn = true
                    }
                }
                else
                {
                    isBackFromTool = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                    {
                        isTapped = false
                    }
                }
            } )
        }
        
        if isTranstitonGoingOn
        {
            let tool = toolsList.getTool(for: selectedTool)
            
            HStack(alignment: .center) {
                
            Image(systemName: tool.icon)
                .foregroundColor(Color(tool.iconColor))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 50).fill(Color(tool.iconBackground))
                )
                //.matchedGeometryEffect(id: "Icon", in: animation)
                .animation(.default)
            
            Text(tool.title)
                .bold()
                .font(.title2)
                .matchedGeometryEffect(id: "title", in: animation)
                .animation(.default)
            
            }
            .padding()
            .matchedGeometryEffect(id: "stack", in: animation)
        }
        }
    }
    
    private func getBackgroundView() -> some View
    {
        GeometryReader{ geo in

            VStack
            {

            }.onAppear(perform: { DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){isBackgroundScrolling = false}})

        }

        
    }
  
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

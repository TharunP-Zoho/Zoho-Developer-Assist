//
//  ToolList.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 14/05/21.
//

import Foundation
import SwiftUI

struct ToolList: Hashable
{
    struct ToolObject: Hashable
    {
        var id: Tool
        var title: String
        var description: String
        var icon: String
        var iconColor: String
        var iconBackground: String
    }
    var tools: [ToolObject] =
        {
            var tools = [ToolObject]()
            
            tools.append((ToolObject(id: .buildNumberChanger,
                          title: "Build Number Changer",
                          description: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.",
                          icon: "building.columns",
                          iconColor: "BuildIcon",
                          iconBackground: "BuildIconBackground")))
            
            tools.append((ToolObject(id: .empty1,
                          title: "Empty",
                          description: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.",
                          icon: "building.columns",
                          iconColor: "BuildIcon",
                          iconBackground: "BuildIconBackground")))
            
            tools.append(ToolObject(id: .empty2,
                          title: "Empty ",
                          description: "This app is used to change the build number easy and safe, so please try the. You can also get push app to git, check once.",
                          icon: "building.columns",
                          iconColor: "BuildIcon",
                          iconBackground: "BuildIconBackground"))
            
            return tools
        }()
    
    func getViewForTool(_ id: Tool, backHandler: @escaping () -> Void) -> some View
    {
        VStack{
            switch id {
            case .buildNumberChanger:
                BuildNumberEditorView(backHandler: backHandler)
            default:
                EmptyView()
            }
        }
    }
    
    func getTool(for givenTool: Tool) -> ToolObject
    {
        for tool in tools
        {
            if tool.id == givenTool
            {
                return tool
            }
        }
        
        return tools[0]
    }

    
    
    // ------------------- Background Developement Tool Images ---------------------
    
    var backgroundDevelopementToolImages: [String] = ["AndroidStudio", "Bitbucket", "Creator", "CSS", "eclipse", "GitHub", "GitLab", "HTML", "Java", "JS", "JSON", "Kotlin", "Obj-C", "Python", "Regex", "SQL-Lite", "SQL", "Swift", "SwiftUI", "TomCat", "UIKit", "Xcode", "XML"]
    
    func getPosition(without lastSendNumber: inout Int) -> Int
    {
        let list = [0, 1, 2]
        var currentList = [Int]()
        
        list.forEach() { integer in
            if integer != lastSendNumber
            {
                currentList.append(integer)
            }
        }
        
        let randomNumber = currentList.randomElement() ?? 0
        lastSendNumber = randomNumber
        
        return randomNumber
    }
    
    func getImage(for image: String) -> some View
    {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
    
}

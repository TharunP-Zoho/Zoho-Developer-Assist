//
//  Zoho_Developer_AssistApp.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

@main
struct Zoho_Developer_AssistApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView().frame(minWidth: 1000, idealWidth: 1000, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

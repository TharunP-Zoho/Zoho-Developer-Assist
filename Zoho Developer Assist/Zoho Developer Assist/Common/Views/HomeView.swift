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
    var body: some View {
        
        VStack{
            
            Text("Zoho Developer Assist")
                .bold()
                .font(.title)
                .padding()
                .padding()
            
            HStack(spacing: 20){
                
                getButtonFor(title: "Build ^", action: {})
                    
                getButtonFor(title: "Empty", action: {} )
                
                getButtonFor(title: "Empty", action: {} )
                
            }
        }
        
    }
    
    private func getButtonFor(title: String, action: () -> Void) -> some View
    {
        Button(action: { showingSheet = true }, label: {
            Text(title)
                .bold()
                .font(.title2)
                .foregroundColor(.white)
        })
        .frame(width: 150, height: 150, alignment: .center)
        .buttonStyle(NeumorphicButtonStyle(bgColor: Color("HomeButtonBG")))
        .sheet(isPresented: $showingSheet) {
                    BuildNumberEditorView().frame(minWidth: 800, idealWidth: 800, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
            
        
        
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

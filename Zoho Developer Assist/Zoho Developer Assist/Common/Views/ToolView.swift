//
//  ButtonStyle.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 07/05/21.
//

import SwiftUI

struct ToolView: View
{
    var id: Tool
    var title: String
    var describtion: String
    var icon: String
    var iconColor: String
    var iconBackground: String
    var selectedTool: Binding<Tool>
    
    //Animation
    var isTapped: Binding<Bool>
    
    
    @State private var tap = false
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Image(systemName: icon)
                .foregroundColor(Color(iconColor))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20).fill(Color(iconBackground))
                )
            
            Spacer()
            Text(title)
                .bold()
                .font(.title3)
            
            Spacer()
            Text(describtion)
                .foregroundColor(Color.gray)
                .font(.callout)
                .clipped()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10).fill(Color("ToolBackground")).shadow(radius: tap ? 0 : 10)
                
        )
        .frame(width: 250, height: 200)
        
        .onTapGesture {
            tap = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                tap = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                tap = false
                isTapped.wrappedValue = true
                selectedTool.wrappedValue = id
            }
        }
        .scaleEffect(tap ? 0.98 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6))
        
        }
    
    
    
}

//
//  Collapsible.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 10/05/21.
//

import SwiftUI

struct Collapsible<Content: View, LabelContent: View>: View
{
    @State var label: () -> HStack<LabelContent>
    @State var content: () -> Content
    
    @State private var collapsed: Bool = false
    
    var body: some View {
        VStack {
            HStack
            {
                Image(systemName: self.collapsed ? "chevron.left": "chevron.down" )
                self.label()
                Spacer()
            }
            .onTapGesture
            {
                self.collapsed.toggle()
            }
            .padding(.bottom, 1)
            .background(Color.white.opacity(0.01))
            
            VStack {
                self.content().allowsHitTesting(!collapsed)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .animation(.easeOut)
            .transition(.slide)
        }
    }
}

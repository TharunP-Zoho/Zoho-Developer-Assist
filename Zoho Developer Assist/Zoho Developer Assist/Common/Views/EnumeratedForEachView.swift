//
//  EnumeratedTesel.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 30/05/21.
//

import SwiftUI

struct EnumeratedForEach<ItemType, ID , ContentView: View>: View {
    let data: [ItemType]
    let content: (Int, ItemType) -> ContentView
    let id: KeyPath<Data.Element, ID>
    
    init(_ data: [ItemType], id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Int, ItemType) -> ContentView) {
        self.data = data
        self.content = content
        self.id = id
    }
    
    var body: some View {
        ForEach(Array(self.data.enumerated()), id: \.offset) { idx, item in
            self.content(idx, item)
        }
    }
}

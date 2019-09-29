//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var topStories: DataModel
    
    var body: some View {
        NavigationView {
            List(topStories.items) { (item: Item) in
                HStack {
                    Text(item.title ?? "")
                    Text(item.text ?? "")
                }
            }
        }.onAppear {
            _ = DataProvider.shared.refreshTopStories()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        var items = [Item]()
        items.append(Item(id: 1,
                          deleted: false,
                          type: ItemType.story,
                          by: "gkpnk",
                          time: Date(),
                          text: "test test 1",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: nil,
                          score: 100,
                          title: "test1",
                          descendantsCount: 0))
        
        items.append(Item(id: 2,
                          deleted: false,
                          type: ItemType.story,
                          by: "gkpnk",
                          time: Date(),
                          text: "test test 2",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: nil,
                          score: 100,
                          title: "test2",
                          descendantsCount: 0))
        
        let topStories = DataModel()
        topStories.items = items
        topStories.error = nil
        
        return HomeView(topStories: topStories)
    }
}

//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var dataModel: ItemsDataModel
    
    var body: some View {
        NavigationView {
            // todo: try foreach per video
            List(dataModel.items) {
                ItemCellView(item: $0)
            }.navigationBarTitle(Text("Top Stories"))
                .padding([.leading, .trailing], -20)
        }.onAppear {
            UITableView.appearance().separatorColor = .clear
            _ = DataProvider.shared.refreshDataModel(self.dataModel)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        var items = [Item]()
        items.append(Item(id: 1,
                          deleted: false,
                          type: ItemType.story,
                          by: "foobar",
                          time: Date(),
                          text: "test test 1",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1NS",
                          score: 312,
                          title: "WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO",
                          descendantsCount: 30))
        
        items.append(Item(id: 2,
                          deleted: false,
                          type: ItemType.story,
                          by: "foobar",
                          time: Date(),
                          text: "test test 2",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1N",
                          score: 100,
                          title: "test2",
                          descendantsCount: 0))
        
        let topStories = ItemsDataModel(.topStories)
        topStories.items = items
        topStories.error = nil
        
        return HomeView(dataModel: topStories)
    }
}

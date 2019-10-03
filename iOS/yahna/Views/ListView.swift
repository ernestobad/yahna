//
//  ListView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/1/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @State var dataModel: ItemsDataModel
    
    var body: some View {
        NavigationView {
            List(dataModel.items) { (item) in
                ItemCellView(item: item)
//                NavigationLink(destination: ItemView(item: item)) {
//                    ItemCellView(item: item, showingWebview: self.$showingWebview, webViewUrl: self.$webViewUrl)
//                }.padding(.trailing, -20)
            }.navigationBarTitle(Text(dataModel.parentId.title ?? ""))
                .padding(.horizontal, -20)
        }.onAppear {
            UITableView.appearance().separatorColor = .clear
            _ = DataProvider.shared.refreshDataModel(self.dataModel)
        }.onDisappear() {
            
        }
    }
}

struct ListView_Previews: PreviewProvider {
    
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
        
        return ListView(dataModel: topStories)
    }
}

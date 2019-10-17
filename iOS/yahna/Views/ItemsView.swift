//
//  ItemsView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/1/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI
import Combine

struct ItemsView: View {
    @ObservedObject var viewModel: ItemsViewModel
    
    var body: some View {
        NavigationView {
            StatesView(viewModel: viewModel, error: { DefaultErrorView() }, empty: { DefaultEmptyView() }) {
                GeometryReader { geometry in
                    CollectionView(self.viewModel.items,
                                   refresh: { DataProvider.shared.refreshViewModel(self.viewModel, force: true).map({ _ -> Void in }).eraseToAnyPublisher() },
                                   cellSize: ItemCellView.calcCellSize) { (item) in
                        ItemCellView(item: item,
                                     availableWidth: geometry.size.width)
                    }
                    .navigationBarTitle(Text(self.viewModel.parentId.title ?? ""), displayMode: NavigationBarItem.TitleDisplayMode.inline)
                }
            }
        }.onAppear {
            DataProvider.shared.refreshViewModel(self.viewModel)
        }
    }
}

struct ItemsView_Previews: PreviewProvider {
    
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
                          poll: nil,
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
                          poll: nil,
                          url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1N",
                          score: 100,
                          title: "test2",
                          descendantsCount: 0))
        
        let topStories = ItemsViewModel(.topStories)
        topStories.items = items
        
        return ItemsView(viewModel: topStories)
    }
}

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
    
    let tab: Tab
    
    @ObservedObject var viewModel: ItemsViewModel
    
    private var scrollToTopCancellable: AnyCancellable?
    
    init(tab: Tab, viewModel: ItemsViewModel) {
        self.tab = tab
        self.viewModel = viewModel
        
        scrollToTopCancellable = NavigationHelper.shared.scrollToTopPublisher(tab: tab)
            .sink {
                viewModel.contentOffset = .zero
        }
    }
    
    var body: some View {
        NavigationView {
            StatesView(viewModel: viewModel,
                       error: { DefaultErrorView() },
                       empty: { DefaultEmptyView() }) {
                        GeometryReader { geometry in
                            CollectionView(self.viewModel.items,
                                           contentOffset: self.$viewModel.contentOffset,
                                           refresh: { DataProvider.shared.refreshViewModel(self.viewModel, force: true).map({ _ -> Void in }).eraseToAnyPublisher() },
                                           cellSize: ItemCellView.cellSize) { (item) in
                                            ItemCellView(item: item,
                                                         availableWidth: geometry.size.width)
                            }
                            .navigationBarTitle(Text(self.viewModel.parentId.title ?? ""),
                                        displayMode: NavigationBarItem.TitleDisplayMode.inline)
                }
            }
        }.onAppear {
            DataProvider.shared.refreshViewModel(self.viewModel)
        }
    }
}

struct ItemsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let topStories = ItemsViewModel(.topStories)
        topStories.items = PreviewData.items
        
        return ItemsView(tab: .home, viewModel: topStories)
    }
}

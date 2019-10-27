//
//  ItemAndCommentsView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/2/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct ItemAndCommentsView: View {
    
    @ObservedObject var viewModel: ItemViewModel
    
    var body: some View {
        GeometryReader { geometry in
            CollectionView(self.viewModel.item.all ?? [Item](),
                           contentOffset: self.$viewModel.contentOffset,
                           refresh: { DataProvider.shared.refreshViewModel(self.viewModel, force: true).map({ _ -> Void in }).eraseToAnyPublisher() },
                           cellSize: ItemAndCommentsView.cellSize) { (item) in
                            
                            if item.type == .story {
                                ItemView(viewModel: self.viewModel, availableWidth: geometry.size.width)
                            } else if item.type == .comment {
                                CommentView(item: item, availableWidth: geometry.size.width)
                            } else {
                                EmptyView()
                            }
            }.onAppear {
                DataProvider.shared.refreshViewModel(self.viewModel)
            }
        }
    }
    
    static func cellSize(_ item: Item, _ availableWidth: CGFloat) -> CGSize {
        if item.type == .story {
            return ItemView.cellSize(item, availableWidth)
        } else if item.type == .comment {
            return CommentView.cellSize(item, availableWidth)
        } else {
            return .zero
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        let item = PreviewData.items[0]
        
        let itemView = ItemAndCommentsView(viewModel: ItemViewModel(item))
        
        return Group {
            itemView.environment(\.colorScheme, .light)
            itemView.environment(\.colorScheme, .dark)
        }.background(Color(UIColor.systemBackground))
    }
}

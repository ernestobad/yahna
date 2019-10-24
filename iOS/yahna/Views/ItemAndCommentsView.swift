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
    
    var item : Item {
        viewModel.item
    }
    
    var body: some View {
        GeometryReader { geometry in
            CollectionView(self.viewModel.item.allItems ?? [Item](),
                           contentOffset: self.$viewModel.contentOffset,
                           refresh: { DataProvider.shared.refreshViewModel(self.viewModel, force: true).map({ _ -> Void in }).eraseToAnyPublisher() },
                           cellSize: ItemAndCommentsView.cellSize) { (item) in
                            
                            if item.type == .story {
                                ItemView(item: item, availableWidth: geometry.size.width)
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
        
        let item = Item(id: 1,
                        deleted: false,
                        type: ItemType.story,
                        by: "foobar",
                        time: Date(),
                        text: "Foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar foo bar.",
                        dead: false,
                        parent: nil,
                        poll: nil,
                        url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1NS",
                        score: 312,
                        title: "WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO",
                        descendantsCount: 30)
        
        let itemView = ItemAndCommentsView(viewModel: ItemViewModel(item))
        
        return Group {
            itemView.environment(\.colorScheme, .light)
            itemView.environment(\.colorScheme, .dark)
        }.background(Color(UIColor.systemBackground))
    }
}

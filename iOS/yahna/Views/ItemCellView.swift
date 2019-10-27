//
//  ItemCellView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/29/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI
import Combine

class NavigationLinkActiveWrapper: ObservableObject {
    @Published var value: Bool = false {
        didSet {
            if value {
                NavigationHelper.shared.onItemViewPushed()
            } else {
                NavigationHelper.shared.onItemViewPopped()
            }
        }
    }
}

struct ItemCellView: View {
    
    var item: Item
    
    let availableWidth: CGFloat
    
    @ObservedObject var navigationLinkActive: NavigationLinkActiveWrapper
    
    init(item: Item, availableWidth: CGFloat) {
        self.item = item
        self.availableWidth = availableWidth
        navigationLinkActive = NavigationLinkActiveWrapper()
    }
    
    var body: some View {
        ZStack {
            NavigationLink(destination: ItemAndCommentsView(viewModel: DataProvider.shared.itemViewModel(item)),
                           isActive: $navigationLinkActive.value) { EmptyView() }
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    bySection
                    titleSection
                    if item.url != nil { linkSection }
                    footerSection
                }.padding(.horizontal, 12)
                Divider()
            }.padding(.top, 8)
        }
    }
    
    var bySection: some View {
        HStack(spacing: 0) {
            Text(verbatim: item.by ?? "")
            Text(verbatim: "・")
            Text(verbatim: item.time.toTimeString())
        }
        .foregroundColor(Color(UIColor.systemGray))
        .font(Fonts.caption.font)
        .fixedSize(horizontal: false, vertical: true)
        .onTapGesture {
            self.navigationLinkActive.value = true
        }
    }
    
    var titleSection: some View {
        Text(verbatim: item.title ?? "")
            .font(Fonts.body.font)
            .foregroundColor(Color.init(UIColor.label))
            .lineLimit(nil)
        .onTapGesture {
            self.navigationLinkActive.value = true
        }
    }
    
    var linkSection: some View {
        TextView(attributedText: item.attributedLink,
                 linkAttributes: item.linkAttributes,
                 availableWidth: availableWidth - 12*2,
                 maximumNumberOfLines: 1,
                 lineBreakMode: .byTruncatingTail)
    }
    
    var footerSection: some View {
        HStack(spacing:4) {
            Text(verbatim: item.pointsString)
            Text(verbatim: "・")
            Text(verbatim: item.commentsString)
        }
        .foregroundColor(Color(UIColor.systemGray))
        .font(Fonts.caption.font)
        .fixedSize(horizontal: false, vertical: true)
        .onTapGesture {
            self.navigationLinkActive.value = true
        }
    }
        
    static func cellSize(_ item: Item, _ availableWidth: CGFloat) -> CGSize {
        
        let titleWidth =  availableWidth - 12*2
        
        let vSpacing: CGFloat = 8
        let bySectionHeight: CGFloat = 17.0
        let titleSectionHeight: CGFloat = item.title?.height(availableWidth: titleWidth, font: Fonts.title.uiFont) ?? 0
        let linkSectionHeight: CGFloat = 19.3
        let footerSectionHeight: CGFloat = 17
        let dividerHeight: CGFloat = 1
        
        let height: CGFloat =
            vSpacing + bySectionHeight +
                vSpacing + titleSectionHeight +
                (item.url != nil ? vSpacing + linkSectionHeight : 0) +
                vSpacing + footerSectionHeight +
                vSpacing + dividerHeight
        
        return CGSize(width: availableWidth, height: height)
    }
}

struct ItemCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let item = PreviewData.items[0]
        
        let itemCellView = ItemCellView(item: item,
                                        availableWidth: 414)
        
        return Group {
            itemCellView.environment(\.colorScheme, .light)
           itemCellView.environment(\.colorScheme, .dark)
        }.previewLayout(.fixed(width: 414, height: 300)).background(Color(UIColor.systemBackground))
    }
}

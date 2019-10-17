//
//  ItemCellView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/29/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct ItemCellView: View {
    
    var item: Item
    
    let availableWidth: CGFloat
    
    @ObservedObject var webViewState = WebViewState()
    
    var body: some View {
        NavigationLink(destination: ItemView(viewModel: ItemViewModel(item))) {
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
    }
    
    var titleSection: some View {
        Text(verbatim: item.title ?? "")
            .font(Fonts.body.font)
            .foregroundColor(Color.init(UIColor.label))
            .lineLimit(nil)
    }
    
    var linkSection: some View {
        TextView(attributedText: item.attributedLink,
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
    }
        
    static func calcCellSize(_ item: Item, _ availableWidth: CGFloat) -> CGSize {
        
        let titleSectionHeight: CGFloat
        if let title = item.title {
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.title.uiFont]
            titleSectionHeight = (title as NSString).boundingRect(with: CGSize(width: availableWidth - 12*2,
                                                                        height: CGFloat.greatestFiniteMagnitude),
                                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                           attributes: attributes,
                                                           context: nil).size.height
        } else {
            titleSectionHeight = 0
        }
        
        let vSpacing: CGFloat = 8
        let bySectionHeight: CGFloat = 17.0
        let linkSectionHeight: CGFloat = 19.3
        let footerSectionHeight: CGFloat = 17
        let separatorHeight: CGFloat = 1
        
        let height: CGFloat =
            vSpacing + bySectionHeight + vSpacing + titleSectionHeight + (item.url != nil ? vSpacing + linkSectionHeight : 0) + vSpacing + footerSectionHeight + vSpacing + separatorHeight
        
        return CGSize(width: availableWidth, height: height)
    }
}

struct ItemCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let item = Item(id: 1,
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
                        title: "WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO",
                        descendantsCount: 30)
        
        let itemCellView = ItemCellView(item: item, availableWidth: 414)
        
        return Group {
            itemCellView.environment(\.colorScheme, .light)
           itemCellView.environment(\.colorScheme, .dark)
        }.previewLayout(.fixed(width: 414, height: 300)).background(Color(UIColor.systemBackground))
    }
}

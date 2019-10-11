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
        VStack(alignment: .leading, spacing: 8) {
            bySection.padding(.horizontal, 16)
            NavigationLink(destination: ItemView(viewModel: ItemViewModel(item))) {
                titleSection.padding(.horizontal, 16)
            }
            if item.url != nil {
                linkSection.padding(.horizontal, 16)
            }
            footerSection.padding(.horizontal, 16)
            Divider()
        }.padding(.top, 8)
    }
    
    var bySection: some View {
        HStack(spacing: 0) {
            Text(verbatim: "@\(item.by ?? "")")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            Text(verbatim: "・")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            Text(verbatim: item.time.toTimeString())
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
        }.fixedSize(horizontal: false, vertical: true)
    }
    
    var titleSection: some View {
        Text(verbatim: item.title ?? "")
            .font(Fonts.body.font)
            .lineLimit(nil)
    }
    
    var linkSection: some View {
        TextView(attributedText: item.attributedLink,
                 availableWidth: availableWidth - 32,
                 maximumNumberOfLines: 1,
                 lineBreakMode: .byTruncatingTail)
    }
    
    var footerSection: some View {
        HStack(spacing:4) {
            
            Text(verbatim: "\(item.score ?? 0) points")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
            Text(verbatim: "・")
                .foregroundColor(Color(UIColor.systemGray2))
                .font(Fonts.caption.font)
            
            Text(verbatim: "\(item.descendantsCount ?? 0) comments")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
        }.fixedSize(horizontal: false, vertical: true)
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

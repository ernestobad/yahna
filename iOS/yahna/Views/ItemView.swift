//
//  ItemView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/2/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct ItemView: View {
    
    @ObservedObject var webViewState = WebViewState()
    
    @ObservedObject var viewModel: ItemViewModel
    
    var item : Item {
        viewModel.item
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 8) {
                    self.titleSection
                    if !(self.item.url?.isEmpty ?? true) {
                        TextView(attributedText: self.item.attributedLink,
                                 availableWidth: geometry.size.width - 24,
                                 maximumNumberOfLines: 1,
                                 lineBreakMode: .byTruncatingTail)
                    }
                    self.bySection
                    if !(self.item.text?.isEmpty ?? true) {
                        TextView(attributedText: self.item.attributedText,
                                 availableWidth: geometry.size.width-24)
                    }
                    self.footer
                    Divider()
                    
                    StatesView(viewModel: self.viewModel, error: { EmptyView() }, empty: { EmptyView() }) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(self.item.kids) { item in
                                CommentView(item: item,
                                            depth: 0,
                                            availableWidth: geometry.size.width-24)
                            }
                        }
                    }
                    
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)
                
                Rectangle().fill(Color.clear)
            }
            .onAppear {
                DataProvider.shared.refreshViewModel(self.viewModel)
            }
        }
    }
    
    var titleSection: some View {
        VStack(alignment: .leading) {
            
            Text(verbatim: item.title ?? "")
                .font(Fonts.title.font)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
        }
    }
    
    var bySection: some View {
        HStack(spacing: 0) {
            Text(verbatim: item.by ?? "")
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
    
    var footer: some View {
        HStack(spacing:4) {
            
            Text(verbatim: item.pointsString)
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
            Text(verbatim: "・")
                .foregroundColor(Color(UIColor.systemGray2))
                .font(Fonts.caption.font)
            
            Text(verbatim: item.commentsString)
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
            Spacer()
            
            TextView(attributedText: self.item.attributedHNLink,
                     availableWidth: 100)
            
        }.fixedSize(horizontal: false, vertical: true)
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
        
        let itemView = ItemView(viewModel: ItemViewModel(item))
        
        return Group {
            itemView.environment(\.colorScheme, .light)
            itemView.environment(\.colorScheme, .dark)
        }.background(Color(UIColor.systemBackground))
    }
}

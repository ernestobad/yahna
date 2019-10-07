//
//  ItemView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/2/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct ItemView: View {
    
    @EnvironmentObject var webViewState: WebViewState
    
    @ObservedObject var viewModel: ItemViewModel
    
    var item : Item {
        viewModel.item
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            
            VStack(alignment: .leading, spacing: 8) {
                titleSection
                if !(item.url?.isEmpty ?? true) {
                    linkSection
                }
                bySection
                if !(item.text?.isEmpty ?? true) {
                    textSection
                }
                footer
                Divider()
                
                ForEach(item.kids) { item in
                    CommentView(depth: 0, item: item)
                }
            }
                        
        }.padding(.top, 50)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                DataProvider.shared.refreshViewModel(self.viewModel)
        }
        
    }
    
    var titleSection: some View {
        VStack(alignment: .leading) {
            
            Text(verbatim: item.title ?? "")
                .font(Fonts.title.font)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
        }.padding(.horizontal)
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
        }.padding([.leading, .trailing])
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var textSection: some View {
        VStack(alignment: .leading) {
            Text(verbatim: item.text ?? "")
                .font(Fonts.body.font)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(.horizontal)
    }
    
    var linkSection: some View {
        Button(action: {
            if let urlString = self.item.url, let url = URL(string: urlString) {
                           self.webViewState.url = url
                           self.webViewState.isShowing = true
                       }
            
        }) {
            Text(verbatim: item.urlWithoutProtocol)
                .lineLimit(1)
                .foregroundColor(Color(UIColor.systemBlue))
                .font(Fonts.body.font)
                .padding(.horizontal)
        }
    }
    
    var footer: some View {
        HStack(spacing:4) {
            
            Text(verbatim: "\(item.score ?? 0) points")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
            Text(verbatim: "・")
                .foregroundColor(Color(UIColor.systemGray2))
                .font(Fonts.caption.font)
            
            Image(systemName: "bubble.left.and.bubble.right")
                .resizable()
                .frame(width: 19, height: 16, alignment: .center)
                .foregroundColor(Color(UIColor.systemGray))
            
            Text(verbatim: "\(item.descendantsCount ?? 0)")
                .foregroundColor(Color(UIColor.systemGray))
                .font(Fonts.caption.font)
            
        }.padding(.horizontal)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct ItemView_Previews: PreviewProvider {
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
        
        let itemView = ItemView(viewModel: ItemViewModel(item))
            .environmentObject(WebViewState())
        
        return Group {
            itemView.environment(\.colorScheme, .light)
            itemView.environment(\.colorScheme, .dark)
        }.background(Color(UIColor.systemBackground))
    }
}

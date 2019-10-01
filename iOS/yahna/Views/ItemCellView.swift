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
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(spacing: 0) {
                Text(verbatim: "@\(item.by ?? "")").foregroundColor(Color(UIColor.systemGray)).font(.subheadline)
                Text(verbatim: "・").foregroundColor(Color(UIColor.systemGray2)).font(.subheadline)
                Text(verbatim: item.time.toTimeString()).foregroundColor(Color(UIColor.systemGray2)).font(.subheadline)
                Spacer()
                Text(verbatim: item.domain ).foregroundColor(Color(UIColor.systemTeal)).font(.subheadline)
            }.padding([.leading, .trailing])
                .fixedSize()
            
            HStack {
                Text(verbatim: item.title ?? "")
                    .font(.body)
                    .lineLimit(nil)
            }.padding([.leading, .trailing])
            
            HStack(spacing:4) {
                
                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: 14, height: 14, alignment: .center)
                    .foregroundColor(Color(UIColor.systemGray))
                
                Text(verbatim: "\(item.score ?? 0)")
                    .foregroundColor(Color(UIColor.systemGray))
                    .font(.subheadline)
                
                Spacer()
                    .fixedSize()
                    .frame(width: 20, height: 16, alignment: .center)
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .resizable()
                    .frame(width: 19, height: 16, alignment: .center)
                    .foregroundColor(Color(UIColor.systemGray))
                
                Text(verbatim: "\(item.descendantsCount ?? 0)")
                    .foregroundColor(Color(UIColor.systemGray))
                    .font(.subheadline)
                
                }.padding([.leading, .trailing])
            .fixedSize()
            Divider()
        }
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
                        childOrder: 1,
                        poll: nil,
                        pollOptionOrder: nil,
                        url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1NS",
                        score: 312,
                        title: "WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO",
                        descendantsCount: 30)
        
        let itemCellView = ItemCellView(item: item)
        
        return Group {
            itemCellView.environment(\.colorScheme, .light)
           itemCellView.environment(\.colorScheme, .dark)
        }.previewLayout(.fixed(width: 300, height: 300)).background(Color(UIColor.systemBackground))
    }
}

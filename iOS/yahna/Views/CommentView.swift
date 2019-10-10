//
//  CommentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/6/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct CommentView: View {
    
    let item: Item
    
    let depth: Int
    
    let availableWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                bySection
                textSection
            }
            
            ForEach(item.kids) { item in
                CommentView(item: item,
                            depth: self.depth+1,
                            availableWidth: self.availableWidth-10)
                    .padding(.leading, 10)
            }
        }
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
    
    var textSection: some View {
        TextView(attributedText: self.item.attributedText,
                 availableWidth: availableWidth)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let item = Item(id: 2921983,
                        deleted: false,
                        type: ItemType.comment,
                        by: "norvig",
                        time: Date(),
                        text: "Aw shucks, guys ... you make me blush with your compliments.<p>Tell you what, Ill make a deal: I'll keep writing if you keep reading. K?",
                        dead: false,
                        parent: 2921506,
                        poll: nil,
                        url: nil,
                        score: nil,
                        title: "",
                        descendantsCount: 30)
        
        return CommentView(item: item, depth: 0, availableWidth: 300)
    }
}

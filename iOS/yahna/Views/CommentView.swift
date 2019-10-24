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
    
    let availableWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                bySection
                textSection
            }.padding(.leading, CommentView.leftPadding(item))
        }.padding(.horizontal, 12)
            .frame(minWidth: 0, maxWidth: .infinity,
                   minHeight: 0, maxHeight: .infinity,
                   alignment: .leading)
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
                 availableWidth: CommentView.textWidth(item, availableWidth))
    }
    
    static func leftPadding(_ item: Item) -> CGFloat {
        CGFloat(((item.depth ?? 0) - 1) * 12)
    }
    
    static func textWidth(_ item: Item, _ availableWidth: CGFloat) -> CGFloat {
        return (availableWidth - 24) - CommentView.leftPadding(item)
    }
    
    static func cellSize(_ item: Item, _ availableWidth: CGFloat) -> CGSize {
        
        let vSpacing: CGFloat = 8
        let bySectionHeight: CGFloat = 17.0
        let textSectionHeight: CGFloat = item.attributedText?.height(availableWidth: CommentView.textWidth(item, availableWidth),
                                                                     font: Fonts.body.uiFont) ?? 0
        
        return CGSize(width: availableWidth,
                      height: vSpacing + bySectionHeight +
                        vSpacing + textSectionHeight + vSpacing)
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
        
        return CommentView(item: item, availableWidth: 300)
    }
}

//
//  ItemView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/23/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

struct ItemView: View {
    
    let item: Item
    
    let availableWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            self.titleSection
            if !(self.item.url?.isEmpty ?? true) {
                TextView(attributedText: self.item.attributedLink,
                         linkAttributes: self.item.linkAttributes,
                         availableWidth: availableWidth - 24,
                         maximumNumberOfLines: 1,
                         lineBreakMode: .byTruncatingTail)
            }
            self.bySection
            if !(self.item.text?.isEmpty ?? true) {
                TextView(attributedText: self.item.attributedText,
                         availableWidth: availableWidth-24)
            }
            self.footer
            Divider()
        }.padding(.horizontal, 12)
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
    
    static func cellSize(_ item: Item, _ availableWidth: CGFloat) -> CGSize {
        
        let titleWidth =  availableWidth - 12*2
        
        let vSpacing: CGFloat = 8
        let titleSectionHeight: CGFloat = item.title?.height(availableWidth: titleWidth, font: Fonts.title.uiFont) ?? 0
        let linkSectionHeight: CGFloat = 19.3
        let bySectionHeight: CGFloat = 17.0
        let textSectionHeight: CGFloat = item.text?.height(availableWidth: titleWidth, font: Fonts.title.uiFont) ?? 0
        let footerSectionHeight: CGFloat = 17
        let dividerHeight: CGFloat = 1
        
        let height: CGFloat =
            vSpacing + titleSectionHeight +
                (item.url != nil ? vSpacing + linkSectionHeight : 0) +
                vSpacing + bySectionHeight +
                (item.text != nil ? vSpacing + textSectionHeight : 0) +
                vSpacing + footerSectionHeight +
                vSpacing + dividerHeight
        
        return CGSize(width: availableWidth, height: height)
    }
}

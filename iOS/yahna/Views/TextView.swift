//
//  TextView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/7/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

class MyTextView: UITextView {
    
    var intrinsicSize: CGSize = CGSize.zero
    
    override var intrinsicContentSize: CGSize {
        return self.intrinsicSize
    }
}

struct TextView: UIViewRepresentable {
    
    let attributedText: NSAttributedString?
    
    let availableWidth: CGFloat
    
    let maximumNumberOfLines: Int
    
    let lineBreakMode: NSLineBreakMode
    
    init(attributedText: NSAttributedString?,
         availableWidth: CGFloat = CGFloat.greatestFiniteMagnitude,
         maximumNumberOfLines: Int = 0,
         lineBreakMode: NSLineBreakMode = .byWordWrapping) {
        self.attributedText = attributedText
        self.availableWidth = availableWidth
        self.maximumNumberOfLines = maximumNumberOfLines
        self.lineBreakMode = lineBreakMode
    }
    
    func makeUIView(context: Context) -> MyTextView {
        let textView = MyTextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        textView.textContainer.maximumNumberOfLines = maximumNumberOfLines
        textView.textContainer.lineBreakMode = lineBreakMode
        
        textView.setContentHuggingPriority(.required, for: .horizontal)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .horizontal)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        return textView
    }
    
    func updateUIView(_ textView: MyTextView, context: Context) {
        textView.attributedText = attributedText
        textView.intrinsicSize = textView.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.invalidateIntrinsicContentSize()
    }
}
struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        
        let encodedString = "If you&#x27;re earning 300k (estimated from the almost 150k you said you pay in taxes), are you really in the upper middle class? from this article [1], 300k salary puts you in the top 5% of income earners. i don&#x27;t know how you figure that makes you upper middle class?<p>[1]: <a href=\"https:&#x2F;&#x2F;www.investopedia.com&#x2F;personal-finance&#x2F;how-much-income-puts-you-top-1-5-10&#x2F;\" rel=\"nofollow\">https:&#x2F;&#x2F;www.investopedia.com&#x2F;personal-finance&#x2F;how-much-incom...</a>"
        
        let attributedString = encodedString.attributedStringFromHtmlEncodedString()
        
        return
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    GeometryReader { geometry in
                        TextView(attributedText: attributedString,
                                 availableWidth: 414)
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    Text(verbatim: "x")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    TextView(attributedText: attributedString,
                             availableWidth: 414)
                    Text(verbatim: "x")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    TextView(attributedText: attributedString,
                             availableWidth: 414)
                    Text(verbatim: "x")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    TextView(attributedText: attributedString,
                             availableWidth: 414)
                    Text(verbatim: "x")
                }
        }
    }
}

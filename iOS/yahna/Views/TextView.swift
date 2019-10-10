//
//  TextView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/7/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    
    let attributedText: NSAttributedString

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        textView.isEditable = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}
struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        
        let encodedString = "If you&#x27;re earning 300k (estimated from the almost 150k you said you pay in taxes), are you really in the upper middle class? from this article [1], 300k salary puts you in the top 5% of income earners. i don&#x27;t know how you figure that makes you upper middle class?<p>[1]: <a href=\"https:&#x2F;&#x2F;www.investopedia.com&#x2F;personal-finance&#x2F;how-much-income-puts-you-top-1-5-10&#x2F;\" rel=\"nofollow\">https:&#x2F;&#x2F;www.investopedia.com&#x2F;personal-finance&#x2F;how-much-incom...</a>"
        
        return
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    TextView(attributedText: encodedString.attributedStringFromHtmlEncodedString()!)
                    Text(verbatim: "x")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "@user")
                    TextView(attributedText: encodedString.attributedStringFromHtmlEncodedString()!)
                    Text(verbatim: "x")
                }
            }
    }
}

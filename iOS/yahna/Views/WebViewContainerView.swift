//
//  WebViewContainerView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/4/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct WebViewContainerView: View {
    
    @EnvironmentObject var webViewState: WebViewState
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button(action: { self.webViewState.hide() }) {
                    Text(Strings.closeWebViewButtonTitle.localizedStringKey)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = self.webViewState.url {
                        UIApplication.shared.open(url)
                    }
                    self.webViewState.hide()
                }) {
                    Image(systemName: "safari")
                        .frame(width: 25, height: 25, alignment: .center)
                }
            }.padding([.trailing, .leading])
                .padding([.top, .bottom], 10)
            
            Divider()
            
            WebView(url: webViewState.url)
            
        }.background(Color.init(UIColor.systemGroupedBackground))
    }
}

struct WebViewContainerView_Previews: PreviewProvider {
    static var previews: some View {
        let webViewState = WebViewState()
        webViewState.isShowing = true
        webViewState.url = URL(string: "https://google.com")
        return WebViewContainerView().environmentObject(webViewState)
    }
}

//
//  WebView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/3/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

import WebKit
import SwiftUI

struct WebView : UIViewRepresentable {
    
    var url: URL?

    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
      
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            webView.loadHTMLString("<html><body><p></p></body></html>", baseURL: nil)
        }
    }
}

class WebViewState: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var url: URL? = nil
}

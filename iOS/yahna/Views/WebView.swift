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
import SafariServices

struct WebView : UIViewRepresentable {
    
    var url: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
      
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            webView.load(URLRequest(url: url))
            webView.navigationDelegate = context.coordinator
        } else {
            webView.loadHTMLString("<html><body><p></p></body></html>", baseURL: nil)
        }
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("--- Navigation success")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("--- Navigation failed with error: \(error)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("--- Provisional Navigation failed with error: \(error)")
        }
    }
}

class WebViewState: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var url: URL? = nil
    
    func show(url: URL) {
        self.url = url
        self.isShowing = true
    }
    
    func hide() {
        self.isShowing = false
        self.url = nil
    }
}

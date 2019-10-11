//
//  StatesView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/5/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct StatesView<ErrorV, EmptyV, Content, ViewModel>: View where ErrorV : View, EmptyV : View, Content : View, ViewModel : RefreshableViewModel {

    var viewModel: ViewModel
    
    var error: () -> ErrorV
    
    var empty: () -> EmptyV
    
    var content: () -> Content
    
    var shouldShowEmptyView: Bool {
        viewModel.isEmpty && !viewModel.state.isRefreshing && viewModel.state.error == nil
    }
    
    var shouldShowErrorView: Bool {
        viewModel.isEmpty && !viewModel.state.isRefreshing && viewModel.state.error != nil
    }
    
    var shouldShowLoadingView: Bool {
        viewModel.isEmpty && viewModel.state.isRefreshing
    }
    
    var shouldShowContent: Bool {
        !viewModel.isEmpty
    }
    
    var body: some View {
        // Content
        if self.shouldShowContent {
            return AnyView(self.content())
        }
        
        // Loading
        if self.shouldShowLoadingView {
            return AnyView(DefaultProgressView())
        }
        
        // Error
        if self.shouldShowErrorView {
            return AnyView(self.error())
        }
        
        if self.shouldShowEmptyView {
            return AnyView(self.empty())
        }
        
        return AnyView(EmptyView())
    }
}

struct DefaultProgressView: View {
    var body: some View {
        ActivityIndicator(isAnimating: .constant(true), style: .large)
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
    }
}

struct DefaultEmptyView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "moon.zzz")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100, alignment: .center)
            Text(Strings.emptyViewMessage.localizedStringKey)
        }
        .foregroundColor(Color.init(UIColor.systemGray2))
    }
}

struct DefaultErrorView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100, alignment: .center)
            Text(Strings.errorMessage.localizedStringKey)
        }
    }
}

//
//  StatesView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/5/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct StatesView<Content>: View where Content : View {

    var viewModel: ItemsViewModel
    
    var content: () -> Content
    
    var shouldShowEmptyView: Bool {
        viewModel.items.isEmpty && !viewModel.state.isRefreshing && viewModel.state.error == nil
    }
    
    var shouldShowErrorView: Bool {
        viewModel.items.isEmpty && !viewModel.state.isRefreshing && viewModel.state.error != nil
    }
    
    var shouldShowLoadingView: Bool {
        viewModel.items.isEmpty && viewModel.state.isRefreshing
    }
    
    var shouldShowContent: Bool {
        !viewModel.items.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .center) {

            // Content
            self.content()
                .disabled(!self.shouldShowContent)
                .opacity(self.shouldShowContent ? 1 : 0)

            // Loading
            ActivityIndicator(isAnimating: .constant(true), style: .large)
                .disabled(!self.shouldShowLoadingView)
                .opacity(self.shouldShowLoadingView ? 1 : 0)
            
            // Error
            VStack {
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100, height: 100, alignment: .center)
                Text(Strings.errorMessage.localizedStringKey)
            }
            .foregroundColor(Color.init(UIColor.systemGray2))
            .disabled(!self.shouldShowErrorView)
                .opacity(self.shouldShowErrorView ? 1 : 0)
            
            // Empty
            VStack {
                Image(systemName: "moon.zzz")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100, height: 100, alignment: .center)
                Text(Strings.emptyViewMessage.localizedStringKey)
            }
            .foregroundColor(Color.init(UIColor.systemGray2))
            .disabled(!self.shouldShowEmptyView)
                .opacity(self.shouldShowEmptyView ? 1 : 0)
            
        }
    }
}

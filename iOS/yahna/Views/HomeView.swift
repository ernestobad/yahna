//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        TabView {
            ItemsView(viewModel: DataProvider.shared.topStories)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            
            ItemsView(viewModel: DataProvider.shared.newStories)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("New")
            }
            
            ItemsView(viewModel: DataProvider.shared.askStories)
                .tabItem {
                    Image(systemName: "questionmark.square")
                    Text("Ask")
            }
            
            ItemsView(viewModel: DataProvider.shared.showStories)
                .tabItem {
                    Image(systemName: "eye")
                    Text("Show")
            }
            
            ItemsView(viewModel: DataProvider.shared.jobStories)
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Jobs")
            }
        }.edgesIgnoringSafeArea(.top)
        .onAppear {
            
            DataProvider.shared.refreshViewModel(DataProvider.shared.topStories)
            DataProvider.shared.refreshViewModel(DataProvider.shared.newStories)
            DataProvider.shared.refreshViewModel(DataProvider.shared.askStories)
            DataProvider.shared.refreshViewModel(DataProvider.shared.showStories)
            DataProvider.shared.refreshViewModel(DataProvider.shared.jobStories)
            
            UINavigationBar.appearance().largeTitleTextAttributes = [.font : Fonts.largeTitle.uiFont]
            UINavigationBar.appearance().titleTextAttributes = [.font : Fonts.title.uiFont]
            UITableView.appearance().separatorColor = .clear
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeView()
    }
}

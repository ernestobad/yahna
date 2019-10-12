//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @State var topStories = ItemsViewModel(.topStories)
    @State var newStories = ItemsViewModel(.newStories)
    @State var askStories = ItemsViewModel(.askStories)
    @State var showStories = ItemsViewModel(.showStories)
    @State var jobStories = ItemsViewModel(.jobStories)
    
    var body: some View {
        
        TabView {
            ItemsView(viewModel: topStories)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            
            ItemsView(viewModel: newStories)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("New")
            }
            
            ItemsView(viewModel: askStories)
                .tabItem {
                    Image(systemName: "questionmark.square")
                    Text("Ask")
            }
            
            ItemsView(viewModel: showStories)
                .tabItem {
                    Image(systemName: "eye")
                    Text("Show")
            }
            
            ItemsView(viewModel: jobStories)
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Jobs")
            }
        }.onAppear {
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

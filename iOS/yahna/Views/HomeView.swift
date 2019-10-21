//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

enum Tab : String {
    
    case home
    case new
    case ask
    case show
    case jobs
    
    var notificationName: Notification.Name {
        return Notification.Name("tab.\(self.rawValue)")
    }
}

final class SelectedItem: ObservableObject {
    
    @Published var value: Tab = .home {
        didSet {
            NavigationHelper.shared.onTabItemTapped(tab: value)
        }
    }
}

struct HomeView: View {
    
    @ObservedObject private var selectedItemOb = SelectedItem()
    
    var body: some View {
        
        TabView(selection: $selectedItemOb.value) {
            
            ItemsView(tab: .home, viewModel: DataProvider.shared.topStories).tabItem {
                Image(systemName: "house")
                Text("Home")
            }.tag(Tab.home)
            
            ItemsView(tab: .new, viewModel: DataProvider.shared.newStories).tabItem {
                Image(systemName: "rays")
                Text("New")
            }.tag(Tab.new)
            
            ItemsView(tab: .ask, viewModel: DataProvider.shared.askStories).tabItem {
                Image(systemName: "questionmark.circle")
                Text("Ask")
            }.tag(Tab.ask)
            
            ItemsView(tab: .show, viewModel: DataProvider.shared.showStories).tabItem {
                Image(systemName: "eye")
                Text("Show")
            }.tag(Tab.show)
            
            ItemsView(tab: .jobs, viewModel: DataProvider.shared.jobStories).tabItem {
                Image(systemName: "briefcase")
                Text("Jobs")
                }.tag(Tab.jobs)
            
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

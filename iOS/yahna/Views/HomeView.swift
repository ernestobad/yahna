//
//  ContentView.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/14/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var webViewState: WebViewState
    
    @State var topStories = ItemsDataModel(.topStories)
    @State var newStories = ItemsDataModel(.newStories)
    @State var askStories = ItemsDataModel(.askStories)
    @State var showStories = ItemsDataModel(.showStories)
    @State var jobStories = ItemsDataModel(.jobStories)
    
    var body: some View {
        
        TabView {
            ItemsView(dataModel: topStories)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            
            ItemsView(dataModel: newStories)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("New")
            }
            
            ItemsView(dataModel: askStories)
                .tabItem {
                    Image(systemName: "questionmark.square")
                    Text("Ask")
            }
            
            ItemsView(dataModel: showStories)
                .tabItem {
                    Image(systemName: "eye")
                    Text("Show")
            }
            
            ItemsView(dataModel: jobStories)
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Jobs")
            }
        }.sheet(isPresented: $webViewState.isShowing, onDismiss: { self.webViewState.url = nil; }) {
            WebViewContainerView()
                .environmentObject(self.webViewState)
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        var items = [Item]()
        items.append(Item(id: 1,
                          deleted: false,
                          type: ItemType.story,
                          by: "foobar",
                          time: Date(),
                          text: "test test 1",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1NS",
                          score: 312,
                          title: "WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO, WeWork says will file to withdraw IPO",
                          descendantsCount: 30))
        
        items.append(Item(id: 2,
                          deleted: false,
                          type: ItemType.story,
                          by: "foobar",
                          time: Date(),
                          text: "test test 2",
                          dead: false,
                          parent: nil,
                          childOrder: 1,
                          poll: nil,
                          pollOptionOrder: nil,
                          url: "https://www.reuters.com/article/us-wework-ipo/wework-says-will-file-to-withdraw-ipo-idUSKBN1WF1N",
                          score: 100,
                          title: "test2",
                          descendantsCount: 0))
        
        let topStories = ItemsDataModel(.topStories)
        topStories.items = items
        topStories.error = nil
        
        return HomeView()
    }
}

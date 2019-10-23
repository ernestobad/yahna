//
//  NavigationViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/21/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class NavigationHelper {
    
    static let shared = NavigationHelper()
    
    private init() {
    }
    
    private(set) var isItemViewPushed: Bool = false
    
    private(set) var selectedTab: Tab = .home
    
    private let passthroughSubject = PassthroughSubject<Tab, Never>()
    
    func onTabItemSelected(tab: Tab) {
        if selectedTab == tab {
            passthroughSubject.send(tab)
        }
        selectedTab = tab
    }
    
    func onItemViewPushed() {
        isItemViewPushed = true
    }
    
    func onItemViewPopped() {
        isItemViewPushed = false
    }
    
    func scrollToTopPublisher(tab: Tab) -> AnyPublisher<Void, Never> {
        passthroughSubject
            .filter({ $0 == tab && !self.isItemViewPushed })
            .map({ _ -> Void in })
            .eraseToAnyPublisher()
    }
    
    func popItemViewPublisher() -> AnyPublisher<Void, Never> {
        passthroughSubject
            .filter({ _ in self.isItemViewPushed })
            .map({ _ -> Void in })
            .eraseToAnyPublisher()
    }
}

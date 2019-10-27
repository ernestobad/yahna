//
//  CommentNavControlView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/25/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

struct CommentNavButton: ViewModifier {

    func body(content: Content) -> some View {
        content
            .frame(width: 20, height: 20, alignment: .center)
            .padding(5)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.blue, lineWidth: 1)
        )
    }
}

struct CommentNavControlView: View {
        
    let stepOutAction: (() -> Void)?
    
    let stepIntoAction: (() -> Void)?
    
    let stepUpAction: (() -> Void)?
    
    let stepDownAction: (() -> Void)?
    
    let stepOutDisabled: Bool
    
    let stepIntoDisabled: Bool
    
    let stepUpDisabled: Bool
    
    let stepDownDisabled: Bool
    
    init(stepOutAction: (() -> Void)? = nil,
         stepIntoAction: (() -> Void)? = nil,
         stepUpAction: (() -> Void)? = nil,
         stepDownAction: (() -> Void)? = nil,
         stepOutDisabled: Bool = false,
         stepIntoDisabled: Bool = false,
         stepUpDisabled: Bool = false,
         stepDownDisabled: Bool = false) {
        self.stepOutAction = stepOutAction
        self.stepIntoAction = stepIntoAction
        self.stepDownAction = stepDownAction
        self.stepUpAction = stepUpAction
        self.stepOutDisabled = stepOutDisabled
        self.stepIntoDisabled = stepIntoDisabled
        self.stepUpDisabled = stepUpDisabled
        self.stepDownDisabled = stepDownDisabled
    }
    
    let side = CGFloat(25)
    
    var body: some View {
        ZStack {
            Button(action: {
                self.stepOutAction?()
            }) {
                Image("stepOut")
                    .resizable()
                    .modifier(CommentNavButton())
                    .disabled(stepOutDisabled)
                
            }.position(x: side*0.5, y: side*1.5)
            
            Button(action: {
                self.stepUpAction?()
            }) {
                Image("stepOverUp")
                    .resizable()
                    .modifier(CommentNavButton())
                    .disabled(stepUpDisabled)
            }.position(x: side*1.5, y: side*0.5)
            
            Button(action: {
                self.stepDownAction?()
            }) {
                Image("stepOverDown")
                    .resizable()
                    .modifier(CommentNavButton())
                    .disabled(stepDownDisabled)
            }.position(x: side*1.5, y: side*2.5)
            
            Button(action: {
                self.stepIntoAction?()
            }) {
                Image("stepInto")
                    .resizable()
                    .modifier(CommentNavButton())
                    .disabled(stepIntoDisabled)
            }.position(x: side*2.5, y: side*1.5)
        }
        .frame(width: side*3, height: side*3)
    }
}

struct CommentNavControlView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let topStories = ItemsViewModel(.topStories)
        topStories.items = PreviewData.items
        
        return ZStack {
            ItemsView(tab: .home, viewModel: topStories)
            CommentNavControlView()
            .position(x: 300, y: 700)
        }
    }
}

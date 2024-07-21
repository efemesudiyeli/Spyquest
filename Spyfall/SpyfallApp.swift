//
//  SpyfallApp.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI

@main
struct SpyfallApp: App {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainMenuView(viewModel: viewModel)
            }
        }
    }
}

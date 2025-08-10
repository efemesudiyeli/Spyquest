//
//  SpyfallApp.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI
import RevenueCat
import Firebase


@main
struct SpyfallApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var viewModel = GameViewModel()
    
    init() {
        Purchases.configure(withAPIKey: "appl_moqHeYbCPILiImIfZoskKVKuqxa")
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainMenuView(viewModel: viewModel)
            }
        }
    }
}

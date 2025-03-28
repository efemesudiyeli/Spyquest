//
//  SettingsView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 29.07.2024.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedLocationSet: LocationSets = CurrentSelectedLocationSet

    
    
    
    func sendEmail() {
            let email = "efemesudiyeli@icloud.com"
            let subject = "Spyquest Feedback"
            let body = "Hello,"
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
            
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Can't open mail app.")
                }
            }
        }
    
    var body: some View {
        List {
            Section {
                Picker("Game Setting", selection: $selectedLocationSet) {
                    Text("First Edition (\(LocationSets.spyfallOne.locations.count)) ").tag(LocationSets.spyfallOne)
                    Text("Second Edition (\(LocationSets.spyfallTwo.locations.count))").tag(LocationSets.spyfallTwo)
                    Text("Combined Edition (\(LocationSets.spyfallCombined.locations.count))").tag(LocationSets.spyfallCombined)
                    Text("Extra Edition (\(LocationSets.spyfallExtra.locations.count))").tag(LocationSets.spyfallExtra)
                    Text("All Edition (\(LocationSets.spyfallAll.locations.count))").tag(LocationSets.spyfallAll)
                }.onChange(of: selectedLocationSet) { newValue in
                    CurrentSelectedLocationSet = newValue
                    Location.locationData = CurrentSelectedLocationSet.locations
                }
                .pickerStyle(.menu)
                
            } header: {
                Text("Location Sets")
            }
            
            Section {
                Button {
                    sendEmail()
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Send Feedback")
                    }
                }
                
                Button {
                    viewModel.requestReview()
                } label: {
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Text("Rate Us")
                    }
                }

            } header: {
                    Text("Feedback")
            } footer: {
                Text("We would love for you to rate our app and share your feedback with us. Thank you!")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        
    }
}

#Preview {
    NavigationStack {
    SettingsView(viewModel: GameViewModel(isSampleData: true))
    }
}

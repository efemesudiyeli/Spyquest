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
        VStack {
            List {
                Section {
                    Picker("Current Setting:", selection: $selectedLocationSet) {
                        ForEach(LocationSets.locationSets, id: \.self) { locationSet in
                            Text("\(locationSet.rawValue) (\(locationSet.locations.count))")
                                .tag(locationSet)
                        }
                        ForEach(LocationSets.premiumSets, id: \.self) { premiumSet in
                            if viewModel.isAdsRemoved {
                                Text("\(premiumSet.rawValue) (\(premiumSet.locations.count))")
                                    .tag(premiumSet)
                            } else {
                                HStack {
                                    Text("\(premiumSet.rawValue) (\(premiumSet.locations.count))")
                                        .foregroundStyle(.gray)
                                    Image(systemName: "crown.fill")
                                }
                                .tag(premiumSet)
                                .selectionDisabled()
                                
                            }
                        }
                    }
                    
                    .pickerStyle(.menu)
                    .onChange(of: selectedLocationSet) { _, newValue in
                        CurrentSelectedLocationSet = newValue
                        Location.locationData = CurrentSelectedLocationSet.locations
                    }
                } header: {
                    Text("Game Setting")
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
                
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("Change Language")
                        }
                    }
                } header: {
                    Text("Language")
                } footer: {
                    Text("More languages will be added soon. Please send feedback which one do you want.")
                }
                
                
                
                
            }
            Spacer()
            HStack{
                Spacer()
                if let versionNumber = Bundle.main.releaseVersionNumber, let buildNumber = Bundle.main.buildVersionNumber {
                    Text("v\(versionNumber) b\(buildNumber)")
                        .fontWeight(.ultraLight)
                }
            }.padding(.trailing)

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

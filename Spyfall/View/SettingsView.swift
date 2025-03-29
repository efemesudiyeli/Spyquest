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
                Menu {
                    Button {
                        selectedLocationSet = .spyfallOne
                    } label: {
                        Text("First Edition (\(LocationSets.spyfallOne.locations.count))")
                    }
                    
                    Button {
                        selectedLocationSet = .spyfallTwo
                    } label: {
                        Text("Second Edition (\(LocationSets.spyfallTwo.locations.count))")
                    }
                    
                    
                    
                    if viewModel.isAdsRemoved {
                        
                        Button {
                            selectedLocationSet = .spyfallCombined
                        } label: {
                            Text("Combined Edition (\(LocationSets.spyfallCombined.locations.count))")
                        }
                        
                        Button {
                            selectedLocationSet = .spyfallExtra
                        } label: {
                            Text("Extra Edition (\(LocationSets.spyfallExtra.locations.count))")
                        }
                        
                        Button {
                            selectedLocationSet = .spyfallAll
                        } label: {
                            Text("All Edition (\(LocationSets.spyfallAll.locations.count))")
                        }
                        
                        Button {
                            selectedLocationSet = .pirateTheme
                        } label: {
                            Text("Pirate Edition (\(LocationSets.pirateTheme.locations.count))")
                        }
                        
                        Button {
                            selectedLocationSet = .wildWestTheme
                        } label: {
                            Text("Wild West Edition (\(LocationSets.wildWestTheme.locations.count))")
                        }
                    } else {
                        Label {
                            Text("Combined Edition (\(LocationSets.spyfallCombined.locations.count))")
                                .foregroundStyle(.gray)
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                        }

                        Label {
                            Text("Extra Edition (\(LocationSets.spyfallExtra.locations.count))")
                                .foregroundStyle(.gray)
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                        }
                        
                        Label {
                            Text( "All Edition (\(LocationSets.spyfallAll.locations.count))")
                                .foregroundStyle(.gray)
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                        }
                        
                        Label {
                            Text( "Pirate Edition (\(LocationSets.pirateTheme.locations.count))")
                                .foregroundStyle(.gray)
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                        }
                        
                        Label {
                            Text( "Wild West Edition (\(LocationSets.wildWestTheme.locations.count))")
                                .foregroundStyle(.gray)
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                        }
                    }
                } label: {
                    HStack {
                        Text("Location Set")
                        Spacer()
                        Text(":")
                        Spacer()
                        Text("\(selectedLocationSet.rawValue)")
                            .foregroundStyle(.blue)
                    }
                    .padding()
                   
                }.onChange(of: selectedLocationSet) { newValue in
                    CurrentSelectedLocationSet = newValue
                    Location.locationData = CurrentSelectedLocationSet.locations
                }

                
                
                
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

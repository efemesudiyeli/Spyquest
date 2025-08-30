//
//  CreateGameView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI
import RevenueCatUI


struct CreateGameView: View {
   
    
    @ObservedObject var viewModel: GameViewModel
    @State var displayModeTitle: NavigationBarItem.TitleDisplayMode = .large
    @State private var selectedLocationSet: LocationSets = CurrentSelectedLocationSet

    
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    VStack(alignment: .leading) {
                        Text("Select Game Setting")
                            .font(.title2)
                            .bold()
                        
                        Picker("Location Set", selection: $selectedLocationSet) {
                            ForEach(LocationSets.locationSets, id: \.self) { locationSet in
                                Text("\(locationSet.rawValue) (\(locationSet.locations.count))")
                                    .tag(locationSet)
                            }
                            ForEach(LocationSets.premiumSets, id: \.self) { premiumSet in
                                if viewModel.isPremium {
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
                        .padding(.horizontal, -12)
                        .padding(.top, -16)
                        
                        .tint(Color.reverse2)
                        .pickerStyle(.menu)
                        .onChange(of: selectedLocationSet) { _, newValue in
                            CurrentSelectedLocationSet = newValue
                            Location.locationData = CurrentSelectedLocationSet.locations
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Players")
                            .font(.title2)
                            .bold()
                        
                        Text("You'll need at least 3 players. but the game is best played with 4-6 players.")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<viewModel.players.count, id: \.self) { index in
                                TextField("Player \(index + 1) Name", text: $viewModel.players[index].name)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 300)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                viewModel.increasePlayerSlot()
                                if viewModel.players.count >= 5 {
                                    displayModeTitle = .inline
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                            })
                            
                            Button(action: {
                                viewModel.decreasePlayerSlot()
                                if viewModel.players.count < 5 {
                                    displayModeTitle = .large
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Remove")
                                }
                            })
                            
                        }.foregroundStyle(.primary)
                    }
                    
                }
                
                .presentPaywallIfNeeded(
                    requiredEntitlementIdentifier: "Pro",
                    purchaseCompleted: { customerInfo in
                    },
                    restoreCompleted: { customerInfo in
                        // Paywall will be dismissed automatically if "pro" is now active.
                    }
                )
                .padding(40)
                
                Spacer()
                
                NavigationLink {
                    GameView(viewModel: viewModel)
                } label: {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140)
                    
                    
                }
                .disabled(!viewModel.players.allSatisfy({ !$0.name.isEmpty }))
                .padding(.bottom, 60)
                .ignoresSafeArea(.keyboard)
                .foregroundStyle(.primary)
            }
        }
            
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(displayModeTitle)
            .onAppear {
                if !viewModel.isPremium {
                    Task {
                        await viewModel.adCoordinator.loadAd()
                    }
                }
            }
            .onDisappear {
                if !viewModel.isPremium {
                    viewModel.adCoordinator.presentAd()
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

#Preview {
    NavigationStack {
        CreateGameView(viewModel: GameViewModel(isSampleData: true))
    }
   
}

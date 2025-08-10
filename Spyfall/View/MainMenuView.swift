//
//  MainMenuView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State var isPurchasePresenting: Bool = false
    @State var displayPaywall = false
    
    var body: some View {
        VStack {
            Image("spyquestIcon-removebg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .colorMultiply(.primary)
            
            if viewModel.isAdsRemoved {
                VStack {
                    Text("Spyquest")
                        .font(.title)
                        .fontWeight(.black)
                        .padding(.top, -40)
                    Text("Premium")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, -30)
                        .foregroundStyle(.premiumReverse)
                }
            } else {
                Text("Spyquest")
                    .font(.title)
                    .fontWeight(.black)
                    .padding(.top, -40)
            }
            
            VStack {
                Group {
                    NavigationLink(destination: {
                        CreateGameView(viewModel: viewModel)
                    }, label: {
                        HStack {
                            Image(systemName: "plus")
                            Spacer()
                            Text("Create Game")
                            Spacer()
                        }
                    })
                    .frame(width: 180, height: 24)
                    .bold()
                    
                    NavigationLink(destination: {
                        MultiplayerLobbyView(gameViewModel: viewModel)
                    }, label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Spacer()
                            Text("Multiplayer")
                            Spacer()
                        }
                    })
                    .frame(width: 160)
                    
                    NavigationLink(destination: {
                        LocationsView(viewModel: viewModel)
                    }, label: {
                        HStack {
                            Image(systemName: "location")
                            Spacer()
                            Text(NSLocalizedString("Locations", comment: ""))
                            Spacer()
                        }
                    })
                    .frame(width: 160)
                    
                    NavigationLink(destination: {
                        HowToPlayView()
                    }, label: {
                        HStack {
                            Image(systemName: "questionmark")
                            Spacer()
                            Text("How to Play")
                            Spacer()
                        }
                    })
                    .frame(width: 160)
                    Button {
                        displayPaywall.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.premiumReverse)
                            Spacer()
                            
                            VStack {
                                if viewModel.isAdsRemoved {
                                    Text("Change Your Plan")
                                        .foregroundStyle(Color.premiumReverse)
                                } else {
                                    Text("Unlock All Features")
                                        .foregroundStyle(Color.premiumReverse)
                                }
                            }
                            Spacer()
                        }
                    }  .frame(width: 160)
                    
                    NavigationLink {
                        SettingsView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                            Spacer()
                            Text("Settings")
                            Spacer()
                        }
                    }
                    .frame(width: 160)
                }
                .foregroundStyle(Color.reverse)
                .padding()
                .background(.primary.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }.sheet(isPresented: self.$displayPaywall) {
            PaywallView(displayCloseButton: true).tint(Color.red)
        }
        .onChange(of: displayPaywall) { _, isPresented in
            if !isPresented {
                viewModel.checkPurchaseStatus()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.checkPurchaseStatus()
            viewModel.fetchProduct()
            viewModel.finishGame()
            
        }
    }
}

#Preview {
    NavigationStack {
        MainMenuView(viewModel: GameViewModel(isSampleData: true))
    }
}

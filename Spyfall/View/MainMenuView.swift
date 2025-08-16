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
            
            if viewModel.isPremium {
                VStack {
                    Text("Spyquest")
                        .font(.title)
                        .fontWeight(.black)
                        .padding(.top, -40)
                        .fontDesign(.rounded)
                    
                    Text("Premium")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, -30)
                        .foregroundStyle(.premiumReverse)
                        .fontDesign(.monospaced)
                }
            } else {
                Text("Spyquest")
                    .font(.title)
                        .fontWeight(.black)
                        .padding(.top, -40)
                        .fontDesign(.rounded)
            }
            
            VStack {
                Group {
                    NavigationLink(destination: {
                        CreateGameView(viewModel: viewModel)
                    }, label: {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Spacer()
                            Text("Classic Mode")
                            Spacer()
                        }
                    })
                    .frame(width: 180, height: 24)
                    .bold()
                    
                    NavigationLink(
                        destination: {
                            MultiplayerLobbyView(gameViewModel: viewModel)
                        },
                        label: {
                            VStack{
                                Spacer()
                                HStack {
                                    Image(systemName: "globe")
                                    Spacer()
                                    Text("Online Mode")
                                    Spacer()
                                }
                                Spacer()
                            }
                        })
                    .frame(width: 180, height: 24)
                    .bold()
                    .overlay(alignment: .topTrailing){
                        Text("New Mode!")
                            .foregroundStyle(.reverse2)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 80, height: 20)
                            .background(
                                Color.premiumReverse,
                                in: Capsule()
                            )
                            .offset(x: 30, y: -20)
                    }
                    
                    NavigationLink(destination: {
                        LocationsView(viewModel: viewModel, locationSet: CurrentSelectedLocationSet)
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
                                if viewModel.isPremium {
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
                .fontDesign(.rounded)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                
                
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

//
//  MainMenuView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to \n Spyquest")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Spyquest is a game where players ask questions to find the spy, who doesn’t know the location. The spy’s goal is to blend in and figure out the location without being detected.")
                .font(.subheadline)
                .padding()
                .multilineTextAlignment(.center)
            
            VStack {
                Group {
                    NavigationLink(destination: {
                        CreateGameView(viewModel: viewModel)
                    }, label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Spacer()
                            Text("Create Game")
                            Spacer()
                        }
                        
                    })
                    .frame(width: 160)
                    
                    NavigationLink(destination: {
                        LocationsView()
                    }, label: {
                        HStack {
                            Image(systemName: "location.circle.fill")
                            Spacer()
                            Text("Locations")
                            Spacer()
                        }
                    })
                    .frame(width: 160)
                    
                    NavigationLink(destination: {
                        HowToPlayView()
                    }, label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Spacer()
                            Text("How to Play")
                            Spacer()
                        }
                    })
                    .frame(width: 160)
                }
                .foregroundStyle(.white)
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if !viewModel.isAdsRemoved {
                    Button(action: {
                        // Remove ads if payment successfull
                    }, label: {
                        Image(systemName: "crown.fill")
                    })
                } else {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                }
            }
        }
        
        
    }
}

#Preview {
    NavigationStack {
        MainMenuView(viewModel: GameViewModel(isSampleData: true))
    }
}

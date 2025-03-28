//
//  CreateGameView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI


struct CreateGameView: View {
   
    
    @ObservedObject var viewModel: GameViewModel
    @State var displayModeTitle: NavigationBarItem.TitleDisplayMode = .large

    
    
    var body: some View {
        
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Players")
                    .font(.title2)
                    .bold()
                
                Text("You'll need at least 3 players. but the game is best played with 4-6 players.")
                    .fixedSize(horizontal: false, vertical: true)
                
                ForEach(0..<viewModel.players.count, id: \.self) { index in
                    TextField("Player \(index + 1) Name", text: $viewModel.players[index].name)
                        .textFieldStyle(.roundedBorder)
                    
                        .padding(.vertical, 1)
                }
                
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
            .padding(40)
            
            Spacer()
            
            NavigationLink {
                GameView(viewModel: viewModel)
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
            }
            .disabled(!viewModel.players.allSatisfy({ !$0.name.isEmpty }))
            .padding(.bottom)
            .foregroundStyle(.primary)
        }
        .navigationTitle("Create Game")
        .navigationBarTitleDisplayMode(displayModeTitle)
        .onAppear {
            if !viewModel.isAdsRemoved {
                Task {
                    await viewModel.adCoordinator.loadAd()
                }
            }
        }
        .onDisappear {
            if !viewModel.isAdsRemoved {
                viewModel.adCoordinator.presentAd()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateGameView(viewModel: GameViewModel(isSampleData: true))
    }
   
}

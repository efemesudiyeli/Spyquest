//
//  ContentView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State var isPresented: Bool = false
    @State var isRestartAlertPresented: Bool = false
    
    
    var body: some View {
        VStack  {
             
            Label("\(viewModel.formattedTimeInterval(viewModel.timeRemaining))", systemImage: "hourglass")
                .font(.title)
                .bold()
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Spacer()
            
            Text("Tap to see role.")
                .font(.title2)
            
            ForEach(viewModel.players, id: \.self) { player in
                Button(action: {
                    viewModel.showingPlayer = player
                    if viewModel.showingPlayer != nil {
                        isPresented = true
                    }
                }, label: {
                    Text("\(player.name)")
                        .frame(minWidth: 160)
                })
                .padding(.vertical, 5)
                .buttonStyle(BorderedProminentButtonStyle())
            }
            
            Spacer()
            
            Button(action: {
                isRestartAlertPresented.toggle()
            }, label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
            })
            .padding(.bottom)
            .foregroundStyle(.primary)
        }
        
        .alert("Time's up!", isPresented: $viewModel.isTimerFinished) {
            Button(action: {}, label: {
                Text("Dismiss")
            })
        }
        
        .alert("Are you sure you want to restart the game?", isPresented: $isRestartAlertPresented) {
            
            Button(action: {
                viewModel.prepareGame()
            }, label: {
                Text("Restart")
            })
            
            Button(action: {
                print("Restart Cancelled")
            }, label: {
                Text("Cancel")
            })
        }
        .sheet(isPresented: $isPresented, content: {
            Group {
                if let showingPlayer = viewModel.showingPlayer {
                    if showingPlayer.role == .spy {
                        VStack {
                            Image(systemName: "eye.fill")
                            Text("You are the spy!")
                        }
                        .bold()
                    } else {
                        Text("Location: \(viewModel.selectedLocation.name)")
                        Text("Your role is: \(showingPlayer.playerLocationRole!)")
                    }
                } else {
                    Text("Player not found")
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            
        })
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink {
                    LocationsView()
                } label: {
                    Text("Locations")
                }
            }
            
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        GameView(viewModel: GameViewModel(isSampleData: true))
    }
}


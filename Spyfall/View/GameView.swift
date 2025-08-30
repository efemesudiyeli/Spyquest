//
//  ContentView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import SwiftUI
import RevenueCatUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State var isPresented: Bool = false
    @State var isRestartAlertPresented: Bool = false
    @State private var showingLocations = false
    @State private var waitingForSheetClose = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Section
            VStack(spacing: 8) {
                Label("\(viewModel.formattedTimeInterval(viewModel.timeRemaining))", systemImage: "hourglass")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentTransition(.numericText())
                
                Text("Tap to see role.")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Players Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(viewModel.players, id: \.self) { player in
                        Button(action: {
                            viewModel.showingPlayer = player
                            if viewModel.showingPlayer != nil && isPresented == false {
                                isPresented = true
                            }
                        }, label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(String(player.name.prefix(1)).uppercased())
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    )
                                
                                Text(player.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            
            // Restart Button
            Button(action: {
                isRestartAlertPresented.toggle()
            }, label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.primary)
            })
            .padding(.bottom, 20)
        }
        
        .alert("Time's up!", isPresented: $viewModel.isTimerFinished) {
            Button(action: {
                viewModel.finishGame()
                viewModel.requestReview()

            }, label: {
                Text("Dismiss")
            })
        }
        
        .alert("Are you sure you want to restart the game?", isPresented: $isRestartAlertPresented) {
            
            Button(action: {
                viewModel.restartGame()
                viewModel.requestReview()

            }, label: {
                Text("Restart")
            })
            
            Button(action: {

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
                        if let role = showingPlayer.playerLocationRole {
                            Text("Your role is: \(role)")
                        } else {
                            Text("Error: Role not assigned")
                                .foregroundColor(.red)
                        }
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
                Button(action: {
                    if isPresented {
                        isPresented = false
                        waitingForSheetClose = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if waitingForSheetClose {
                                showingLocations = true
                                waitingForSheetClose = false
                            }
                        }
                    } else {
                        showingLocations = true
                    }
                }) {
                    Text(NSLocalizedString("Locations", comment: ""))
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingLocations) {
            NavigationView {
                LocationsView(viewModel: viewModel, locationSet: CurrentSelectedLocationSet)
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.startNewGame()
        }
        
    }
}

#Preview {
    NavigationStack {
        GameView(viewModel: GameViewModel(isSampleData: true))
    }
}



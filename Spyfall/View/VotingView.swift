//
//  VotingView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 16.08.2025.
//
import SwiftUI

struct VotingView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    
    @State private var currentTime: TimeInterval = Date().timeIntervalSince1970
    @State private var timer: Timer? = nil
    @State private var showingSpyGuessAlert = false
    
    private var isCurrentPlayerSpy: Bool {
        guard let currentPlayer = lobby.players.first(where: { $0.name == viewModel.currentPlayerName }) else { return false }
        return currentPlayer.role == .spy
    }
    
    var body: some View {
        VStack() {
            Text("Voting Time!")
                .fontDesign(.rounded)
                .font(.largeTitle)
                .fontWeight(.black)
            
            Text("Who do you think is the spy?")
                .font(.title2)
                .foregroundColor(.secondary)
                .fontDesign(.monospaced)
                .multilineTextAlignment(.center)
            
            if let votingStartAt = lobby.votingStartAt,
               let votingDurationSeconds = lobby.votingDurationSeconds {
                let localNow = currentTime
                let serverNow = localNow + TimeInterval(Double(viewModel.serverTimeOffsetMs) / 1000.0)
                let elapsed = max(0, serverNow - votingStartAt)
                let remaining = max(0, Double(votingDurationSeconds) - elapsed)
                
                Spacer()
                HStack{
                    Image(systemName: "hourglass.circle.fill")
                    
                    Text("\(Int(remaining))s")
                    
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(remaining < 10 ? .red : .primary)
                }.font(.largeTitle)
                    .padding(.top)
                
                if remaining <= 0 {
                    Text("Time's up!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Players to vote for:")
                    .font(.headline)
                    .fontDesign(.rounded)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(lobby.players, id: \.name) { player in
                        if player.name != viewModel.currentPlayerName {
                            Button(action: {
                                viewModel.voteForPlayer(playerName: player.name)
                            }) {
                                VStack(spacing: 8) {
                                    HStack{
                                        Image(systemName: "person.crop.circle.fill")
                                        Spacer()
                                        Text(player.name)
                                        Spacer()
                                        
                                    }.font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    if viewModel.currentVote == player.name {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.reverse2)
                                            .font(.title2)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(Color.reverse2)
                                            .font(.title2)
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.currentVote == player.name ? Color.green.opacity(1) : Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(
                                    color: Color.reverse2,
                                    radius: 0,
                                    x: 2.5,
                                    y: 2
                                )
                            }
                            .disabled(viewModel.currentVote == player.name)
                        }
                    }
                }
                
                Spacer()
                
                if let currentVote = viewModel.currentVote {
                    Text("You voted for: \(currentVote)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            // Remove the manual "End Voting & Reveal" button
            // Voting will end automatically when:
            // 1. Time runs out
            // 2. Everyone has voted AND spy has made a guess
            
            Spacer()
            
        }
        .padding(.horizontal)
        .onAppear {
            currentTime = Date().timeIntervalSince1970
            startReliableTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert("Guess Submitted!", isPresented: $showingSpyGuessAlert) {
            Button("OK") { }
        } message: {
            Text("Your location guess has been submitted. Good luck!")
        }
        .overlay(
            // Always visible bottom sheet for spy
            Group {
                if isCurrentPlayerSpy {
                    VStack {
                        Spacer()
                        SpyGuessSheet(lobby: lobby, viewModel: viewModel, showingAlert: $showingSpyGuessAlert)
                    }
                }
            }
        )
    }
    
    // Remove the private checkVotingEndConditions function
    
    private func startReliableTimer() {
        // Stop any existing timer
        stopTimer()
        
        // Create a more reliable timer using DispatchQueue
        let _ = DispatchQueue.global(qos: .userInteractive)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                // Update current time
                self.currentTime = Date().timeIntervalSince1970
                
                // Check if voting should end automatically
                self.viewModel.checkVotingEndConditions()
            }
        }
        
        // Ensure timer runs even during scroll
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

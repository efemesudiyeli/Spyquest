//
//  GamePlayingView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct GamePlayingView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @State private var timeRemaining: TimeInterval = 8.5 * 60
    @State private var isTimerFinished: Bool = false
    @State private var gameTimer: Timer?
    
    private var currentPlayer: Player? {
        lobby.players.first { $0.name == viewModel.currentPlayerName }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    if let player = currentPlayer, player.role != .spy {
                        Text("Location: \(lobby.location.name)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Time Remaining: \(formattedTime(timeRemaining))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Spacer()
            
            if let player = currentPlayer {
                VStack(spacing: 20) {
                    Text("Your Role")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if player.role == .spy {
                        VStack(spacing: 10) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            
                            Text("You are the SPY!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            Text("Don't get caught! Ask questions to figure out where you are.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("You are a \(NSLocalizedString(player.playerLocationRole ?? "Civilian", comment: ""))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Help your team identify the spy!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            
            VStack(spacing: 15) {
                if isTimerFinished {
                    Button("End Game") {
                        viewModel.endGameForAll()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
                if lobby.hostId == viewModel.currentUser?.uid {
                    HStack(spacing: 15) {
                        Button(NSLocalizedString("End Round For All", comment: "")) {
                            viewModel.startVoting()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player, playerLocationRole: "Tourist"),
        Player(name: "Player 1", role: .player, playerLocationRole: "Lifeguard"),
        Player(name: "Player 2", role: .spy),
        Player(name: "Player 3", role: .player, playerLocationRole: "Vendor")
    ]
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .playing,
        createdAt: Date(),
        selectedLocationSet: LocationSets.spyfallOne
    )
    
    return GamePlayingView(lobby: lobby, viewModel: vm)
}


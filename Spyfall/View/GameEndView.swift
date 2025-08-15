//
//  GameEndView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct GameEndView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    
    private var currentPlayer: Player? {
        lobby.players.first { $0.name == viewModel.currentPlayerName }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main result card
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                            Image(systemName: "flag.checkered.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Game Results")
                                .font(.headline)
                            Text("See how the game ended")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontDesign(.monospaced)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)

                    Divider()

                    // Winner announcement
                    if let votingResult = lobby.votingResult {
                        VStack(spacing: 16) {
                            // Winner section
                            let spyWins = votingResult.spyGuessCorrect == true
                            let playersWin = votingResult.spyCaught || votingResult.spyGuessCorrect == false
                            
                            VStack(spacing: 12) {
                                if spyWins {
                                    HStack(spacing: 8) {
                                        Image(systemName: "eye.fill")
                                            .foregroundColor(.red)
                                        Text("SPY WINS!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    }
                                } else if playersWin {
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.3.fill")
                                            .foregroundColor(.green)
                                        Text("PLAYERS WIN!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                // Outcome description
                                if votingResult.spyCaught {
                                    Text("The spy was caught!")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                } else if !votingResult.spyCaught && votingResult.spyGuessCorrect != true {
                                    Text("The spy got away!")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.vertical, 12)

                        Divider()

                        // Voting details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voting Results")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Most voted player:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(votingResult.mostVotedPlayer)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    Text("The spy was:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(votingResult.spyName)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                                
                                // Spy guess section
                                if let spyGuess = lobby.spyGuess {
                                    HStack {
                                        Text("Spy's guess:")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(spyGuess)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
                                            
                                            if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                                HStack(spacing: 4) {
                                                    Image(systemName: spyGuessCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .foregroundColor(spyGuessCorrect ? .green : .red)
                                                    Text(spyGuessCorrect ? "Correct" : "Wrong")
                                                        .font(.caption)
                                                        .foregroundColor(spyGuessCorrect ? .green : .red)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 12)

                        Divider()

                        // Game details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Game Details")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                if let player = currentPlayer, player.role != .spy {
                                    HStack {
                                        Text("Location was:")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(lobby.location.name)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                HStack {
                                    Text("Players:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(lobby.players.count)")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if lobby.hostId == viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.restartGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(NSLocalizedString("Back to Lobby", comment: ""))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.reverse2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Text("Waiting for host to restart the game...")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .navigationTitle("Game Results")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Game End - Spy Wins") {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player),
        Player(name: "Player 1", role: .player),
        Player(name: "Player 2", role: .spy),
        Player(name: "Player 3", role: .player)
    ]
    let votingResult = VotingResult(
        mostVotedPlayer: "Player 1",
        spyName: "Player 2",
        spyCaught: false,
        voteCounts: ["Player 1": 2, "Player 3": 1],
        spyGuessCorrect: true
    )
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .finished,
        createdAt: Date(),
        votingResult: votingResult,
        spyGuess: "Beach",
        selectedLocationSet: LocationSets.spyfallOne
    )
    vm.currentLobby = lobby
    vm.currentPlayerName = "Player 1"
    
    return NavigationStack {
        GameEndView(lobby: lobby, viewModel: vm)
    }
}

#Preview("Game End - Players Win") {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player),
        Player(name: "Player 1", role: .player),
        Player(name: "Player 2", role: .spy),
        Player(name: "Player 3", role: .player)
    ]
    let votingResult = VotingResult(
        mostVotedPlayer: "Player 2",
        spyName: "Player 2",
        spyCaught: true,
        voteCounts: ["Player 2": 3],
        spyGuessCorrect: false
    )
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .finished,
        createdAt: Date(),
        votingResult: votingResult,
        spyGuess: "Restaurant",
        selectedLocationSet: LocationSets.spyfallOne
    )
    vm.currentLobby = lobby
    vm.currentPlayerName = "Player 1"
    
    return NavigationStack {
        GameEndView(lobby: lobby, viewModel: vm)
    }
}

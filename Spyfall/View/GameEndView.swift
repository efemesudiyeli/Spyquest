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
                            // Winner section - use the calculated result from ViewModel
                            let spyWins = votingResult.spyWins
                            let playersWin = !spyWins
                            
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
                                } else {
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
                                    if votingResult.isTie {
                                        if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                            if spyGuessCorrect {
                                                Text("Vote ended in a tie, but the spy guessed correctly!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.red)
                                                    .fontWeight(.medium)
                                            } else {
                                                Text("Vote ended in a tie, and the spy guessed incorrectly!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                                    .fontWeight(.medium)
                                            }
                                        } else {
                                            Text("Vote ended in a tie, but the spy didn't make a guess!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                                    .fontWeight(.medium)
                                        }
                                    } else {
                                        if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                            if spyGuessCorrect {
                                                Text("The spy was caught, but guessed correctly!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.red)
                                                    .fontWeight(.medium)
                                            } else {
                                                Text("The spy was caught and guessed incorrectly!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                                    .fontWeight(.medium)
                                            }
                                        } else {
                                            Text("The spy was caught and didn't make a guess!")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                                .fontWeight(.medium)
                                        }
                                    }
                                } else if votingResult.isTie {
                                    if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                        if spyGuessCorrect {
                                            Text("Vote ended in a tie, and the spy guessed correctly!")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                                .fontWeight(.medium)
                                        } else {
                                            Text("Vote ended in a tie, and the spy guessed incorrectly!")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                                .fontWeight(.medium)
                                        }
                                    } else {
                                        Text("Vote ended in a tie, and the spy didn't make a guess!")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                            .fontWeight(.medium)
                                    }
                                } else {
                                    if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                        if spyGuessCorrect {
                                            Text("The spy got away and guessed correctly!")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                                .fontWeight(.medium)
                                        } else {
                                            Text("The spy got away but guessed incorrectly!")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                                .fontWeight(.medium)
                                        }
                                    } else {
                                        Text("The spy got away and didn't make a guess!")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                            .fontWeight(.medium)
                                    }
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
                                
                                if votingResult.isTie {
                                    HStack {
                                        Text("Vote result:")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                            Text("TIE")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
                                        }
                                    }
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
                                        HStack(spacing: 4) {
                                           
                                            
                                            if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                                HStack(spacing: 4) {
                                                    Image(systemName: spyGuessCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .foregroundColor(spyGuessCorrect ? .green : .red)
                                        
                                                }
                                            }
                                            Text(spyGuess)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
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
                                HStack {
                                    Text("Location was:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(lobby.location.name)
                                        .fontWeight(.semibold)
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
                    HStack(spacing: 16) {
                        // Restart Game Button
                        Button(action: {
                            viewModel.restartGame()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                Text("Restart Game")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.reverse)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // Back to Lobby Button
                        Button(action: {
                            viewModel.returnToLobbyForAll()
                        }) {
                            HStack {
                                Image(systemName: "house.circle.fill")
                                Text("Back to Lobby")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.reverse)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
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
        spyGuessCorrect: true,
        isTie: false,
        spyWins: true
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
        spyGuessCorrect: false,
        isTie: false,
        spyWins: false
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


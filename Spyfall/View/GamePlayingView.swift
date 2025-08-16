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
    @State private var notes: String = ""
    @State private var showingNotepad: Bool = true
    
    private var currentPlayer: Player? {
        lobby.players.first { $0.name == viewModel.currentPlayerName }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Timer Card
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                            Image(systemName: "timer.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Remaining Time")
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text("Time is running out")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontDesign(.monospaced)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    
                    Divider()
                    
                    // Timer Display
                    VStack(spacing: 8) {
                        Text(formattedTime(timeRemaining))
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .foregroundColor(.blue)
                            .contentTransition(.numericText())
                        
                        if isTimerFinished {
                            Text("Time's up!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .fontDesign(.rounded)
                        } else {
                            Text("Minutes remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontDesign(.monospaced)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Notepad Card
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                            Image(systemName: "note.text")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notepad")
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text("Local notes only")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontDesign(.monospaced)
                        }
                        Spacer()
                        
                        Button(action: {
                            showingNotepad.toggle()
                        }) {
                            Image(systemName: showingNotepad ? "chevron.up" : "chevron.down")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    if showingNotepad {
                        Divider()
                        
                        VStack(spacing: 12) {
                            TextEditor(text: $notes)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            
                            HStack {
                                Button(action: {
                                    notes = ""
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Clear")
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                
                                Spacer()
                                
                                Text("\(notes.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontDesign(.monospaced)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Role & Location Card
                if let player = currentPlayer {
                    VStack(spacing: 0) {
                        // Header
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 48, height: 48)
                                Image(systemName: player.role == .spy ? "eye.circle.fill" : "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(player.role == .spy ? .red : .blue)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Location & Role")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                Text(player.role == .spy ? "Secret spy" : "Keep it secret from the spy.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontDesign(.monospaced)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Content
                        VStack(spacing: 16) {
                            if player.role == .spy {
                                VStack(spacing: 12) {
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.red)
                                    
                                    Text("YOU ARE THE SPY!")
                                        .font(.title2)
                                        .fontWeight(.black)
                                        .foregroundColor(.red)
                                        .fontDesign(.rounded)
                                    
                                    Text("Don't get caught! Ask questions to figure out where you are.")
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .fontDesign(.monospaced)
                                }
                            } else {
                                VStack(spacing: 16) {
                                    // Role Section
                                    VStack(spacing: 8) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.blue)
                                        
                                        Text("You are a")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .fontDesign(.monospaced)
                                        
                                        Text(NSLocalizedString(player.playerLocationRole ?? "Civilian", comment: ""))
                                            .font(.title2)
                                            .fontWeight(.black)
                                            .foregroundColor(.blue)
                                            .fontDesign(.rounded)
                                    }
                                    
                                    Divider()
                                        .padding(.horizontal, 20)
                                    
                                    // Location Section
                                    VStack(spacing: 8) {
                                        Image(systemName: "mappin.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                        
                                        Text("Location")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .fontDesign(.monospaced)
                                        
                                        Text(lobby.location.name)
                                            .font(.title3)
                                            .fontWeight(.black)
                                            .foregroundColor(.green)
                                            .fontDesign(.rounded)
                                    }
                                    
                                    Text("Help your team identify the spy!")
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .fontDesign(.monospaced)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if isTimerFinished {
                    Button(action: {
                        viewModel.endGameForAll()
                    }) {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("End Game")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                if lobby.hostId == viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.startVoting()
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text(NSLocalizedString("End Round For All", comment: ""))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
    }
}

#Preview("Spy Role") {
    let vm = MultiplayerGameViewModel()
    vm.currentPlayerName = "Player 2" // Spy player
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

#Preview("Player Role") {
    let vm = MultiplayerGameViewModel()
    vm.currentPlayerName = "Player 1" // Regular player
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


//
//  WaitingLobbyView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct WaitingLobbyView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @State private var lobbyCodeCopied: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Cohesive card
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                            Image(systemName: "hourglass.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Waiting Lobby")
                                .font(.headline)
                            Text("Share the code and get your friends ready")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontDesign(.monospaced)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)

                    Divider()

                    // Lobby Code
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lobby Code")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(alignment: .center, spacing: 8) {
                            Text("#")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text(lobby.id)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .textSelection(.enabled)
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = lobby.id
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    lobbyCodeCopied = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        lobbyCodeCopied = false
                                    }
                                }
                            }) {
                                Image(systemName: lobbyCodeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(lobbyCodeCopied ? .green : .blue)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.vertical, 12)

                    Divider()

                    // Players
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Players (\(lobby.players.count)/\(lobby.maxPlayers))")
                                .font(.headline)
                            Spacer()
                            if let hostPlayer = lobby.players.first(where: { $0.name == lobby.hostName }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                    Text("Host: \(hostPlayer.name)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(lobby.players, id: \.name) { player in
                                PlayerCard(
                                    player: player,
                                    isHost: player.name == lobby.hostName,
                                    ready: lobby.readyPlayers?[player.name] ?? false
                                )
                                .frame(maxWidth: .infinity, minHeight: 72)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                let isReady = lobby.readyPlayers?[viewModel.currentPlayerName] ?? false
                Button(action: {
                    viewModel.toggleReady()
                }) {
                    HStack {
                        Image(systemName: isReady ? "hand.thumbsdown.fill" : "hand.thumbsup.fill")
                        Text(isReady ? NSLocalizedString("Unready", comment: "") : NSLocalizedString("Ready", comment: ""))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.reverse)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(isReady ? Color.orange : Color.reverse2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if lobby.hostId == viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background((viewModel.areAllPlayersReady(in: lobby) && lobby.players.count >= 2) ? Color.green : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!(viewModel.areAllPlayersReady(in: lobby) && lobby.players.count >= 2))
                } else {
                    Text("Waiting for host to start the game...")
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
        .navigationTitle("Waiting Lobby")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player, isPremium: true),
        Player(name: "Player 1", role: .player, isPremium: false),
        Player(name: "Player 2", role: .spy, isPremium: true),
        Player(name: "Player 3", role: .player, isPremium: false)
    ]
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .waiting,
        createdAt: Date(),
        readyPlayers: [
            "Host Player": true,
            "Player 1": false,
            "Player 2": true,
            "Player 3": false
        ],
        selectedLocationSet: LocationSets.spyfallOne
    )
    vm.currentLobby = lobby
    vm.currentPlayerName = "Player 1"
    
    return NavigationStack {
        WaitingLobbyView(lobby: lobby, viewModel: vm)
    }
}


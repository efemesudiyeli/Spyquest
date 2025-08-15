//
//  RoleRevealView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct RoleRevealView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    
    private func isAllReady(lobby: GameLobby) -> Bool {
        guard let ready = lobby.readyPlayers else { return false }
        let nonHostPlayers = lobby.players.filter { $0.name != lobby.hostName }.map { $0.name }
        return nonHostPlayers.allSatisfy { ready[$0] == true }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 30) {
                Text("Get Ready!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your role will be revealed in:")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("3")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Tap to continue when everyone is ready")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onTapGesture { }
            
            // Ready status and host control
            VStack(spacing: 12) {
                // Ready progress
                if let ready = lobby.readyPlayers {
                    let nonHostReady = ready.filter { $0.key != lobby.hostName }
                    let readyCount = nonHostReady.values.filter { $0 }.count
                    let total = lobby.players.count
                    Text("\(readyCount + 1)/\(total) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    let total = lobby.players.filter { $0.name != lobby.hostName }.count
                    Text("0/\(total) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Ready button for non-hosts
                if lobby.hostId != viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.markCurrentPlayerReady()
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text(NSLocalizedString("Ready", comment: ""))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                
                // Host start button (host does not need to be ready)
                if lobby.hostId == viewModel.currentUser?.uid {
                    Button(action: {
                        if isAllReady(lobby: lobby) {
                            // Move status to playing; countdown will handle reveal and timer
                            viewModel.tryStartIfAllReady()
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(NSLocalizedString("Start", comment: ""))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isAllReady(lobby: lobby) ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isAllReady(lobby: lobby))
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player),
        Player(name: "Player 1", role: .player),
        Player(name: "Player 2", role: .spy),
        Player(name: "Player 3", role: .player)
    ]
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .revealing,
        createdAt: Date(),
        readyPlayers: [
            "Player 1": true,
            "Player 2": true,
            "Player 3": false
        ],
        selectedLocationSet: LocationSets.spyfallOne
    )
    
    return RoleRevealView(lobby: lobby, viewModel: vm)
}

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
        
        VStack {
            
            Text("Get Ready!")
                .font(.largeTitle)
                .fontWeight(.black)
                .fontDesign(.rounded)
            
            Spacer()
            Text("3")
                .font(.system(size: 100, weight: .black))
                .foregroundColor(.blue)
                .fontDesign(.rounded)
                .contentTransition(.numericText())

            
            Spacer()
            
            Text("**Tip:** If someone answers oddly, don’t correct them. Keep your own answer flexible.")
                .fontDesign(.monospaced)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.secondary)

        }
        .onAppear {
            print("Role Reveal View Appeared")
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


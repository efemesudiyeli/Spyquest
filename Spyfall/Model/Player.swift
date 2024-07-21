//
//  Player.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import Foundation

enum Role {
    case player
    case spy
}

struct Player: Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var role: Role?
    var playerLocationRole: String?

}

extension Player {
    static let samplePlayers = [
        Player(name: "Efe", role: .player, playerLocationRole: "Host"),
        Player(name: "Elif", role: .player, playerLocationRole: "Pilot"),
        Player(name: "Nisa", role: .spy)]
}

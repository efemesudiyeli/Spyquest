//
//  Player.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import Foundation

enum Role: String, Codable {
    case player = "player"
    case spy = "spy"
}

struct Player: Hashable, Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var role: Role?
    var playerLocationRole: String?
    var isPremium: Bool = false
}

extension Player {
    static let samplePlayers = [
        Player(name: "Efe", role: .player, playerLocationRole: "Host", isPremium: true),
        Player(name: "Elif", role: .player, playerLocationRole: "Pilot", isPremium: false),
        Player(name: "Nisa", role: .spy, isPremium: true)]
}

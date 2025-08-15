//
//  PlayerCard.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct PlayerCard: View {
    let player: Player
    let isHost: Bool
    let ready: Bool
    private let avatarSize: CGFloat = 26
    private let minHeight: CGFloat = 72
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(player.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    if isHost {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                Text(ready ? "Ready" : "Unready")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
            Spacer(minLength: 8)
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: avatarSize, height: avatarSize)
                .foregroundColor(ready ? .green : .blue)
        }
        .frame(minHeight: minHeight)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("Host Ready") {
    PlayerCard(
        player: Player(name: "Host Player", role: .player),
        isHost: true,
        ready: true
    )
    .padding()
}

#Preview("Player Unready") {
    PlayerCard(
        player: Player(name: "Player 1", role: .player),
        isHost: false,
        ready: false
    )
    .padding()
}

#Preview("Spy Ready") {
    PlayerCard(
        player: Player(name: "Player 2", role: .spy),
        isHost: false,
        ready: true
    )
    .padding()
}

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
                    if player.isPremium {
                        Image(systemName: "star.fill")
                            .foregroundColor(.premiumReverse)
                            .font(.caption)
                    }
                    Text(player.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    if isHost {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.reverse2)
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
        .background(
            Group {
                if player.isPremium {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.15),
                            Color.purple.opacity(0.08),
                            Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color(.systemGray5)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            Group {
                if player.isPremium {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.3),
                                    Color.purple.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
        )
    }
}

#Preview("Host Ready - Regular") {
    PlayerCard(
        player: Player(name: "Host Player", role: .player, isPremium: false),
        isHost: true,
        ready: true
    )
    .padding()
}

#Preview("Player Unready - Regular") {
    PlayerCard(
        player: Player(name: "Player 1", role: .player, isPremium: false),
        isHost: false,
        ready: false
    )
    .padding()
}

#Preview("Host Ready - Premium") {
    PlayerCard(
        player: Player(name: "Host Player", role: .player, isPremium: true),
        isHost: true,
        ready: true
    )
    .padding()
}

#Preview("Player Unready - Premium") {
    PlayerCard(
        player: Player(name: "Player 1", role: .player, isPremium: true),
        isHost: false,
        ready: false
    )
    .padding()
}


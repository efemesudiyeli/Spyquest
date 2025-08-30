//
//  SpyGuessSheet.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 16.08.2025.
//

import SwiftUI

struct SpyGuessSheet: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @Binding var showingAlert: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    @State private var selectedGuess: String? = nil
    
    private let collapsedHeight: CGFloat = 120  // Daha yukarıda, lokasyonların ucundan görünsün
    private let expandedHeight: CGFloat = 400
    private let minDragDistance: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 0) {
            // Content - Her zaman görünür
            VStack(spacing: 16) {
                // Grabber handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity)
                // Header - Her zaman görünür
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make Your Guess!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse indicator
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                
                if isExpanded {
                    Divider()
                    
                    // Location grid - Sadece expanded'da
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(lobby.selectedLocationSet.locations, id: \.id) { location in
                                Button(action: {
                                    selectedGuess = location.nameKey
                                    viewModel.makeSpyGuess(guess: location.nameKey)
                                }) {
                                    VStack(spacing: 8) {
                                        Text(location.name)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .padding()
                                    .background((selectedGuess == location.nameKey) ? Color.red.opacity(0.15) : Color.red.opacity(0.1))
                                    .cornerRadius(16)
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke((selectedGuess == location.nameKey) ? Color.red : Color.red.opacity(0.3), lineWidth: (selectedGuess == location.nameKey) ? 2 : 1)
                                            if selectedGuess == location.nameKey {
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.red)
                                                            .background(
                                                                Circle()
                                                                    .fill(Color(.systemBackground))
                                                                    .frame(width: 22, height: 22)
                                                            )
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    
                    // Selection controls
                    VStack(spacing: 8) {
                        let isOptOutSelected = (selectedGuess ?? "").isEmpty && (selectedGuess != nil)
                        Button(action: {
                            selectedGuess = ""
                            viewModel.spyOptOutGuess()
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle")
                                Text("Skip Guess")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(isOptOutSelected ? Color.red.opacity(0.15) : Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isOptOutSelected ? Color.red : Color.red.opacity(0.3), lineWidth: isOptOutSelected ? 2 : 1)
                                    if isOptOutSelected {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(
                                                    Circle()
                                                        .fill(Color(.systemBackground))
                                                        .frame(width: 22, height: 22)
                                                )
                                        }
                                        .padding(8)
                                    }
                                }
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                } else {
                    // Collapsed state - Lokasyonların ucundan görünsün
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.red)
                        Text("Tap to expand and see all locations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? expandedHeight : collapsedHeight)
        .offset(y: dragOffset)
        .ignoresSafeArea(.keyboard)
        
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.translation.height
                    if isExpanded {
                        // When expanded, only allow dragging down
                        dragOffset = max(0, newOffset)
                    } else {
                        // When collapsed, only allow dragging up
                        dragOffset = min(0, newOffset)
                    }
                }
                .onEnded { value in
                    let dragDistance = value.translation.height
                    
                    if isExpanded {
                        // If dragged down significantly, collapse
                        if dragDistance > minDragDistance {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded = false
                                dragOffset = 0
                            }
                        } else {
                            // Snap back to expanded
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    } else {
                        // If dragged up significantly, expand
                        if dragDistance < -minDragDistance {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded = true
                                dragOffset = 0
                            }
                        } else {
                            // Snap back to collapsed
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
                }
        )
        .onTapGesture {
            // Tap to toggle state
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .onAppear {

            // Initialize selection from existing spy guess if any
            selectedGuess = lobby.spyGuess
        }
    }
}



#Preview("Spy Guess Sheet") {
    let vm = MultiplayerGameViewModel()
    vm.currentPlayerName = "Spy Player"
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player, playerLocationRole: "Tourist"),
        Player(name: "Spy Player", role: .spy),
        Player(name: "Player 3", role: .player, playerLocationRole: "Vendor")
    ]
    let lobby = GameLobby(
        id: "ABC123",
        hostId: "host123",
        hostName: "Host Player",
        location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
        maxPlayers: 6,
        players: samplePlayers,
        status: .voting,
        createdAt: Date(),
        selectedLocationSet: LocationSets.spyfallOne
    )
    vm.currentLobby = lobby
    return SpyGuessSheet(lobby: lobby, viewModel: vm, showingAlert: .constant(false))
        .padding()
        .background(Color(.systemGroupedBackground))
}

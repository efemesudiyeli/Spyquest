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
    
    private let collapsedHeight: CGFloat = 120  // Daha yukarıda, lokasyonların ucundan görünsün
    private let expandedHeight: CGFloat = 400
    private let minDragDistance: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 0) {
            // Content - Her zaman görünür
            VStack(spacing: 16) {
                // Header - Her zaman görünür
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make Your Guess!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        if isExpanded {
                            Text("Try to guess the location before time runs out!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
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
                                    viewModel.makeSpyGuess(guess: location.nameKey)
                                    showingAlert = true
                                }) {
                                    VStack(spacing: 12) {
                                        Text(location.name)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                        
                                        Text("\(location.roles.count) roles")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
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
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        }
        
        .frame(height: isExpanded ? expandedHeight : collapsedHeight)
        .offset(y: dragOffset)
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
            print("DEBUG: SpyGuessSheet loaded")
            print("DEBUG: Current game location: \(lobby.location.nameKey)")
            print("DEBUG: Selected location set: \(lobby.selectedLocationSet.rawValue)")
            print("DEBUG: Available locations count: \(lobby.selectedLocationSet.locations.count)")
        }
    }
}

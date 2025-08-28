import SwiftUI
import UIKit
import FirebaseAuth

struct MultiplayerGameView: View {
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingGameEnd = false
    @State private var timeRemaining: TimeInterval = 8.5 * 60
    @State private var isTimerFinished = false
    @State private var gameTimer: Timer?
    @State private var lobbyCodeCopied: Bool = false
    @State private var showingLocations = false
    
    private var currentPlayer: Player? {
        viewModel.currentLobby?.players.first { $0.name == viewModel.currentPlayerName }
    }
    
    var body: some View {
        VStack {
            if let lobby = viewModel.currentLobby {
                switch lobby.status {
                case .waiting:
                    WaitingLobbyView(lobby: lobby, viewModel: viewModel)
                case .revealing:
                    RoleRevealView(lobby: lobby, viewModel: viewModel)
                case .playing:
                    GamePlayingView(lobby: lobby, viewModel: viewModel)
                case .voting:
                    VotingView(lobby: lobby, viewModel: viewModel)
                case .finished:
                    GameEndView(lobby: lobby, viewModel: viewModel)
                case .cancelled:
                    GameCancelledView()
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationBarBackButtonHidden()
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.leaveLobby()
                    dismiss()
                }) {
                    Image(systemName: "door.left.hand.open")
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingLocations = true
                }) {
                    Text(NSLocalizedString("Locations", comment: ""))
                }
            }
        }
        .onAppear {
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: viewModel.currentLobby?.status) { _, newStatus in
            if newStatus == .playing {
                // Start game timer
                startGameTimer(reset: true)
            } else if newStatus == .waiting {
                // Reset game states when restarting
                showingGameEnd = false
                isTimerFinished = false
                timeRemaining = 8.5 * 60
                gameTimer?.invalidate()
                gameTimer = nil
            } else if newStatus == .voting {
                // Reset voting states
                viewModel.currentVote = nil
                // Close locations sheet when voting starts
                showingLocations = false
            } else if newStatus == .finished || newStatus == .cancelled {
                gameTimer?.invalidate()
                gameTimer = nil
                // Close locations sheet when game ends
                showingLocations = false
            }
        }
        .onChange(of: viewModel.currentLobby?.gameStartAt) { _, _ in
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: viewModel.serverTimeOffsetMs) { _, _ in
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                syncTimerWithServerIfNeeded()
                if let lobby = viewModel.currentLobby, lobby.status == .playing, gameTimer == nil {
                    startGameTimer(reset: false)
                }
            } else if newPhase == .background || newPhase == .inactive {
                // Optionally pause local timer to save resources; server sync will correct on resume
                gameTimer?.invalidate()
                gameTimer = nil
            }
        }
        .alert("Lobby Update", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showingLocations) {
            NavigationView {
                LocationsView(viewModel: viewModel, locationSet: viewModel.currentLobby?.selectedLocationSet ?? .spyfallOne)
            }
        }
    }

    private func isAllReady(lobby: GameLobby) -> Bool {
        guard let ready = lobby.readyPlayers else { return false }
        let nonHostPlayers = lobby.players.filter { $0.name != lobby.hostName }.map { $0.name }
        return nonHostPlayers.allSatisfy { ready[$0] == true }
    }
    
    private func startGameTimer(reset: Bool) {
        if reset {
            timeRemaining = 8.5 * 60
            isTimerFinished = false
        }
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            syncTimerWithServerIfNeeded()
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                gameTimer = nil
                isTimerFinished = true
            }
        }
    }
    

    
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func syncTimerWithServerIfNeeded() {
        guard let lobby = viewModel.currentLobby,
              lobby.status == .playing,
              let startAt = lobby.gameStartAt,
              let duration = lobby.gameDurationSeconds else { return }
        
        let localNow = Date().timeIntervalSince1970
        let serverNow = localNow + TimeInterval(Double(viewModel.serverTimeOffsetMs) / 1000.0)
        let elapsed = max(0, serverNow - startAt)
        let remaining = max(0, Double(duration) - elapsed)
        if abs(remaining - timeRemaining) > 1.5 {
            timeRemaining = remaining
        }
        if remaining <= 0 {
            isTimerFinished = true
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
}

#Preview {
    VotingView(
        lobby: GameLobby(
            id: "ABC123",
            hostId: "host123",
            hostName: "Host Player",
            location: Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor"]),
            maxPlayers: 6,
            players: [
                Player(name: "Host Player", role: .player),
                Player(name: "Player 1", role: .player),
                Player(name: "Player 2", role: .spy),
                Player(name: "Player 3", role: .player),
                Player(name: "Player 4", role: .player)
            ],
            status: .voting,
            createdAt: Date(),
            votingStartAt: Date().timeIntervalSince1970 - 10, // 10 seconds ago
            votingDurationSeconds: 30, selectedLocationSet: LocationSets.spyfallOne
        ),
        viewModel: MultiplayerGameViewModel()
    )
}

#Preview("Waiting Lobby") {
    let vm = MultiplayerGameViewModel()
    let samplePlayers: [Player] = [
        Player(name: "Host Player", role: .player),
        Player(name: "Player 1", role: .player, isPremium: true),
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
    return MultiplayerGameView(viewModel: vm)
}

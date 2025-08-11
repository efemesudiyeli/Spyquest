import SwiftUI
import FirebaseAuth

struct MultiplayerGameView: View {
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingRole = false
    @State private var showingGameEnd = false
    @State private var timeRemaining: TimeInterval = 8.5 * 60
    @State private var isTimerFinished = false
    @State private var gameTimer: Timer?
    
    private var currentPlayer: Player? {
        viewModel.currentRoom?.players.first { $0.name == viewModel.currentPlayerName }
    }
    
    var body: some View {
        VStack {
            if let room = viewModel.currentRoom {
                switch room.status {
                case .waiting:
                    waitingRoomView(room: room)
                case .revealing:
                    roleRevealView(room: room)
                case .playing:
                    if showingRole {
                        gamePlayingView(room: room)
                    } else {
                        roleRevealView(room: room)
                    }
                case .finished:
                    gameEndView(room: room)
                case .cancelled:
                    gameCancelledView(room: room)
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationBarBackButtonHidden()
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.leaveRoom()
                    dismiss()
                }) {
                    Image(systemName: "door.left.hand.open")
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    LocationsView(viewModel: viewModel)
                } label: {
                    Text(NSLocalizedString("Locations", comment: ""))
                }
            }
        }
        .onAppear {
            if let room = viewModel.currentRoom, room.status == .playing, gameTimer == nil {
                startGameTimer(reset: false)
            }
        }
        .onChange(of: viewModel.currentRoom?.status) { _, newStatus in
            if newStatus == .playing {
                // Reveal roles for all and start the timer together
                showingRole = true
                startGameTimer(reset: true)
            } else if newStatus == .waiting {
                // Reset game states when restarting
                showingRole = false
                showingGameEnd = false
                isTimerFinished = false
                timeRemaining = 8.5 * 60
                gameTimer?.invalidate()
                gameTimer = nil
            } else if newStatus == .finished || newStatus == .cancelled || newStatus == .revealing {
                gameTimer?.invalidate()
                gameTimer = nil
            }
        }
        .alert("Room Update", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func waitingRoomView(room: GameRoom) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Waiting Room")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                

                
                VStack(spacing: 5) {
                    Text("Room Code")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(room.id)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .textSelection(.enabled)
                }
            }
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Players (\(room.players.count)/\(room.maxPlayers))")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let hostPlayer = room.players.first(where: { $0.name == room.hostName }) {
                        HStack(spacing: 5) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Host: \(hostPlayer.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(room.players, id: \.name) { player in
                        PlayerCard(player: player, isHost: player.name == room.hostName)
                    }
                }
            }
            
            if room.hostId == viewModel.currentUser?.uid {
                VStack(spacing: 10) {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(room.players.count >= 2 ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(room.players.count < 2)
                    
                    if room.status == .finished {
                        Button(action: {
                            viewModel.restartGame()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(NSLocalizedString("End Round For All", comment: ""))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                }
            } else {
                Text("Waiting for host to start the game...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func gameCancelledView(room: GameRoom) -> some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text(NSLocalizedString("Game Cancelled", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text(NSLocalizedString("Not enough players to continue. Minimum 2 players required.", comment: ""))
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Removed in-content Leave Room per design; use top-left toolbar button instead
        }
        .padding()
    }
    
    private func roleRevealView(room: GameRoom) -> some View {
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
                if let ready = room.readyPlayers {
                    let readyCount = ready.values.filter { $0 }.count
                    Text("\(readyCount)/\(room.players.count) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("0/\(room.players.count) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Ready button for non-hosts
                if room.hostId != viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.markCurrentPlayerReady()
                        viewModel.tryStartIfAllReady()
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
                if room.hostId == viewModel.currentUser?.uid {
                    Button(action: {
                        if isAllReady(room: room) {
                            showingRole = true
                            // move status to playing
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
                        .background(isAllReady(room: room) ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isAllReady(room: room))
                }
            }
            .padding(.horizontal)
        }
    }

    private func isAllReady(room: GameRoom) -> Bool {
        guard let ready = room.readyPlayers else { return false }
        return ready.values.allSatisfy { $0 } && ready.count == room.players.count
    }
    
    private func gamePlayingView(room: GameRoom) -> some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                                if let player = currentPlayer, player.role != .spy {
                Text("Location: \(room.location.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
                    
                    Text("Time Remaining: \(formattedTime(timeRemaining))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if let player = currentPlayer {
                VStack(spacing: 20) {
                    Text("Your Role")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if player.role == .spy {
                        VStack(spacing: 10) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            
                            Text("You are the SPY!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                            Text("Don't get caught! Ask questions to figure out where you are.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("You are a \(NSLocalizedString(player.playerLocationRole ?? "Civilian", comment: ""))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Help your team identify the spy!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            
            VStack(spacing: 15) {
                if isTimerFinished {
                    Button("End Game") {
                        showingGameEnd = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
                // In-content Leave Room removed; only host restart remains
                if room.hostId == viewModel.currentUser?.uid {
                    HStack(spacing: 15) {
                        Button(NSLocalizedString("End Round For All", comment: "")) {
                            viewModel.restartGame()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func gameEndView(room: GameRoom) -> some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                        if let player = currentPlayer, player.role != .spy {
            Text("Location was: \(room.location.name)")
                .font(.title2)
                .foregroundColor(.secondary)
        }
                
                if let spy = room.players.first(where: { $0.role == .spy }) {
                    Text("The spy was: \(spy.name)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            
            HStack(spacing: 15) {
                Button(NSLocalizedString("Leave Room", comment: "")) {
                    viewModel.leaveRoom()
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                
                if room.hostId == viewModel.currentUser?.uid {
                    Button(NSLocalizedString("Back to Lobby", comment: "")) {
                        viewModel.restartGame()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func startGameTimer(reset: Bool) {
        if reset {
            timeRemaining = 8.5 * 60
            isTimerFinished = false
        }
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
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
}

struct PlayerCard: View {
    let player: Player
    let isHost: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(player.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if isHost {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("Waiting...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    MultiplayerGameView(viewModel: MultiplayerGameViewModel())
}

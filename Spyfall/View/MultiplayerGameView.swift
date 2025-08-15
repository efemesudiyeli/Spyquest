import SwiftUI
import UIKit
import FirebaseAuth

struct MultiplayerGameView: View {
    @ObservedObject var viewModel: MultiplayerGameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingRole = false
    @State private var showingGameEnd = false
    @State private var timeRemaining: TimeInterval = 8.5 * 60
    @State private var isTimerFinished = false
    @State private var gameTimer: Timer?
    @State private var revealCountdown: Int = 0
    @State private var revealTimer: Timer?
    @State private var lobbyCodeCopied: Bool = false
    
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
                    if showingRole {
                        GamePlayingView(lobby: lobby, viewModel: viewModel)
                    } else {
                        CountdownView(countdown: revealCountdown)
                    }
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
                NavigationLink {
                    LocationsView(viewModel: viewModel, locationSet: viewModel.currentLobby?.selectedLocationSet ?? .spyfallOne)
                } label: {
                    Text(NSLocalizedString("Locations", comment: ""))
                }
            }
        }
        .onAppear {
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: viewModel.currentLobby?.status) { _, newStatus in
            if newStatus == .playing {
                // Begin 3-2-1 countdown, reveal roles afterwards, then start game timer
                showingRole = false
                startRevealCountdown()
            } else if newStatus == .waiting {
                // Reset game states when restarting
                showingRole = false
                showingGameEnd = false
                isTimerFinished = false
                timeRemaining = 8.5 * 60
                gameTimer?.invalidate()
                gameTimer = nil
                revealTimer?.invalidate()
                revealTimer = nil
                revealCountdown = 0
            } else if newStatus == .voting {
                // Reset voting states
                viewModel.currentVote = nil
            } else if newStatus == .finished || newStatus == .cancelled || newStatus == .revealing {
                gameTimer?.invalidate()
                gameTimer = nil
                revealTimer?.invalidate()
                revealTimer = nil
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
                if let lobby = viewModel.currentLobby, lobby.status == .playing, gameTimer == nil, showingRole {
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
    }
    
//    private func waitingLobbyView(lobby: GameLobby) -> some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                // Cohesive card
//                VStack(spacing: 0) {
//                    // Header
//                    HStack(spacing: 12) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(.systemGray6))
//                                .frame(width: 48, height: 48)
//                            Image(systemName: "hourglass.circle.fill")
//                                .font(.title2)
//                                .foregroundColor(.blue)
//                        }
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("Waiting Lobby")
//                                .font(.headline)
//                            Text("Share the code and get everyone ready")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                                .fontDesign(.monospaced)
//                        }
//                        Spacer()
//                    }
//                    .padding(.vertical, 12)
//
//                    Divider()
//
//                    // Lobby Code
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Lobby Code")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        HStack(alignment: .center, spacing: 8) {
//                            Text("#")
//                                .font(.system(size: 28, weight: .bold, design: .monospaced))
//                                .foregroundColor(.secondary)
//                            Text(lobby.id)
//                                .font(.system(size: 32, weight: .bold, design: .monospaced))
//                                .foregroundColor(.blue)
//                                .textSelection(.enabled)
//                            Spacer()
//                            Button(action: {
//                                UIPasteboard.general.string = lobby.id
//                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
//                                impactFeedback.impactOccurred()
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                    lobbyCodeCopied = true
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                                    withAnimation(.easeOut(duration: 0.2)) {
//                                        lobbyCodeCopied = false
//                                    }
//                                }
//                            }) {
//                                Image(systemName: lobbyCodeCopied ? "checkmark.circle.fill" : "doc.on.doc")
//                                    .font(.system(size: 16, weight: .semibold))
//                            }
//                            .buttonStyle(.plain)
//                            .foregroundColor(lobbyCodeCopied ? .green : .blue)
//                        }
//                        .padding(12)
//                        .background(Color(.systemGray6))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                    }
//                    .padding(.vertical, 12)
//
//                    Divider()
//
//                    // Players
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            Text("Players (\(lobby.players.count)/\(lobby.maxPlayers))")
//                                .font(.headline)
//                            Spacer()
//                            if let hostPlayer = lobby.players.first(where: { $0.name == lobby.hostName }) {
//                                HStack(spacing: 5) {
//                                    Image(systemName: "crown.fill")
//                                        .foregroundColor(.yellow)
//                                    Text("Host: \(hostPlayer.name)")
//                                        .font(.subheadline)
//                                        .fontWeight(.medium)
//                                }
//                            }
//                        }
//
//                        LazyVStack(spacing: 10) {
//                            ForEach(lobby.players, id: \.name) { player in
//                                PlayerCard(
//                                    player: player,
//                                    isHost: player.name == lobby.hostName,
//                                    ready: lobby.readyPlayers?[player.name] ?? false
//                                )
//                                .frame(maxWidth: .infinity, minHeight: 72)
//                            }
//                        }
//                    }
//                    .padding(.vertical, 12)
//                }
//                .padding(.horizontal, 16)
//          
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//
//            }
//            .padding()
//        }
//        .safeAreaInset(edge: .bottom) {
//            VStack(spacing: 12) {
//                if let lobby = viewModel.currentLobby {
//                    let isReady = lobby.readyPlayers?[viewModel.currentPlayerName] ?? false
//                    Button(action: {
//                        viewModel.toggleReady()
//                    }) {
//                        HStack {
//                            Image(systemName: isReady ? "hand.thumbsdown.fill" : "hand.thumbsup.fill")
//                            Text(isReady ? NSLocalizedString("Unready", comment: "") : NSLocalizedString("Ready", comment: ""))
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundColor(.reverse)
//                        .frame(maxWidth: .infinity, minHeight: 48)
//                        .background(isReady ? Color.orange : Color.reverse2)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//
//                    if lobby.hostId == viewModel.currentUser?.uid {
//                        Button(action: {
//                            viewModel.startGame()
//                        }) {
//                            HStack {
//                                Image(systemName: "play.fill")
//                                Text("Start Game")
//                                    .fontWeight(.semibold)
//                            }
//                            .foregroundColor(.reverse)
//                            .frame(maxWidth: .infinity, minHeight: 48)
//                            .background((viewModel.areAllPlayersReady(in: lobby) && lobby.players.count >= 2) ? Color.green : Color.gray)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                        }
//                        .disabled(!(viewModel.areAllPlayersReady(in: lobby) && lobby.players.count >= 2))
//                    } else {
//                        Text("Waiting for host to start the game...")
//                            .font(.caption)
//                            .fontDesign(.monospaced)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.top, 10)
//            .padding(.bottom, 8)
//        
//        }
//        .navigationTitle("Waiting Lobby")
//        .navigationBarTitleDisplayMode(.large)
//    }
    
//    private func gameCancelledView(lobby: GameLobby) -> some View {
//        VStack(spacing: 30) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.system(size: 80))
//                .foregroundColor(.orange)
//            
//            Text(NSLocalizedString("Game Cancelled", comment: ""))
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.orange)
//            
//            Text(NSLocalizedString("Not enough players to continue. Minimum 2 players required.", comment: ""))
//                .font(.title3)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//            
//            // Removed in-content Leave Lobby per design; use top-left toolbar button instead
//        }
//        .padding()
//    }
    
//    private func roleRevealView(lobby: GameLobby) -> some View {
//        VStack(spacing: 30) {
//            VStack(spacing: 30) {
//                Text("Get Ready!")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                
//                Text("Your role will be revealed in:")
//                    .font(.title2)
//                    .foregroundColor(.secondary)
//                
//                Text("3")
//                    .font(.system(size: 80, weight: .bold))
//                    .foregroundColor(.blue)
//                
//                Text("Tap to continue when everyone is ready")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//            .padding()
//            .onTapGesture { }
//            
//            // Ready status and host control
//            VStack(spacing: 12) {
//                // Ready progress
//                if let ready = lobby.readyPlayers {
//                    let nonHostReady = ready.filter { $0.key != lobby.hostName }
//                    let readyCount = nonHostReady.values.filter { $0 }.count
//                    let total = lobby.players.count
//                    Text("\(readyCount + 1)/\(total) ready")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                } else {
//                    let total = lobby.players.filter { $0.name != lobby.hostName }.count
//                    Text("0/\(total) ready")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                
//                
//                
//                // Ready button for non-hosts
//                if lobby.hostId != viewModel.currentUser?.uid {
//                    Button(action: {
//                        viewModel.markCurrentPlayerReady()
//                    }) {
//                        HStack {
//                            Image(systemName: "hand.thumbsup.fill")
//                            Text(NSLocalizedString("Ready", comment: ""))
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    }
//                }
//                
//                // Host start button (host does not need to be ready)
//                if lobby.hostId == viewModel.currentUser?.uid {
//                    Button(action: {
//                        if isAllReady(lobby: lobby) {
//                            // Move status to playing; countdown will handle reveal and timer
//                            viewModel.tryStartIfAllReady()
//                        }
//                    }) {
//                        HStack {
//                            Image(systemName: "checkmark.circle.fill")
//                            Text(NSLocalizedString("Start", comment: ""))
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(isAllReady(lobby: lobby) ? Color.green : Color.gray)
//                        .cornerRadius(10)
//                    }
//                    .disabled(!isAllReady(lobby: lobby))
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
    
    private func isAllReady(lobby: GameLobby) -> Bool {
        guard let ready = lobby.readyPlayers else { return false }
        let nonHostPlayers = lobby.players.filter { $0.name != lobby.hostName }.map { $0.name }
        return nonHostPlayers.allSatisfy { ready[$0] == true }
    }
    
//    private func gamePlayingView(lobby: GameLobby) -> some View {
//        VStack(spacing: 20) {
//            HStack {
//                VStack(alignment: .leading) {
//                    if let player = currentPlayer, player.role != .spy {
//                        Text("Location: \(lobby.location.name)")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                    }
//                    
//                    Text("Time Remaining: \(formattedTime(timeRemaining))")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                }
//                Spacer()
//            }
//            
//            Spacer()
//            
//            if let player = currentPlayer {
//                VStack(spacing: 20) {
//                    Text("Your Role")
//                        .font(.title)
//                        .fontWeight(.bold)
//                    
//                    if player.role == .spy {
//                        VStack(spacing: 10) {
//                            Image(systemName: "eye.fill")
//                                .font(.system(size: 60))
//                                .foregroundColor(.red)
//                            
//                            Text("You are the SPY!")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.red)
//                            
//                            Text("Don't get caught! Ask questions to figure out where you are.")
//                                .font(.body)
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(.secondary)
//                        }
//                    } else {
//                        VStack(spacing: 10) {
//                            Image(systemName: "person.fill")
//                                .font(.system(size: 60))
//                                .foregroundColor(.blue)
//                            
//                            Text("You are a \(NSLocalizedString(player.playerLocationRole ?? "Civilian", comment: ""))")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.blue)
//                            
//                            Text("Help your team identify the spy!")
//                                .font(.body)
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(15)
//            }
//            
//            VStack(spacing: 15) {
//                if isTimerFinished {
//                    Button("End Game") {
//                        viewModel.endGameForAll()
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.red)
//                    .cornerRadius(10)
//                }
//                
//                if lobby.hostId == viewModel.currentUser?.uid {
//                    HStack(spacing: 15) {
//                        Button(NSLocalizedString("End Round For All", comment: "")) {
//                            viewModel.startVoting()
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.green)
//                        .cornerRadius(10)
//                    }
//                }
//            }
//            
//            
//        }
//        .padding()
//    }
    
//    private func gameEndView(lobby: GameLobby) -> some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                // Main result card
//                VStack(spacing: 0) {
//                    // Header
//                    HStack(spacing: 12) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(.systemGray6))
//                                .frame(width: 48, height: 48)
//                            Image(systemName: "flag.checkered.circle.fill")
//                                .font(.title2)
//                                .foregroundColor(.blue)
//                        }
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("Game Results")
//                                .font(.headline)
//                            Text("See how the game ended")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                                .fontDesign(.monospaced)
//                        }
//                        Spacer()
//                    }
//                    .padding(.vertical, 12)
//
//                    Divider()
//
//                    // Winner announcement
//                    if let votingResult = lobby.votingResult {
//                        VStack(spacing: 16) {
//                            // Winner section
//                            let spyWins = votingResult.spyGuessCorrect == true
//                            let playersWin = votingResult.spyCaught || votingResult.spyGuessCorrect == false
//                            
//                            VStack(spacing: 12) {
//                                if spyWins {
//                                    HStack(spacing: 8) {
//                                        Image(systemName: "eye.fill")
//                                            .foregroundColor(.red)
//                                        Text("SPY WINS!")
//                                            .font(.title2)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.red)
//                                    }
//                                } else if playersWin {
//                                    HStack(spacing: 8) {
//                                        Image(systemName: "person.3.fill")
//                                            .foregroundColor(.green)
//                                        Text("PLAYERS WIN!")
//                                            .font(.title2)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.green)
//                                    }
//                                }
//                                
//                                // Outcome description
//                                if votingResult.spyCaught {
//                                    Text("The spy was caught!")
//                                        .font(.subheadline)
//                                        .foregroundColor(.green)
//                                        .fontWeight(.medium)
//                                } else if !votingResult.spyCaught && votingResult.spyGuessCorrect != true {
//                                    Text("The spy got away!")
//                                        .font(.subheadline)
//                                        .foregroundColor(.red)
//                                        .fontWeight(.medium)
//                                }
//                            }
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }
//                        .padding(.vertical, 12)
//
//                        Divider()
//
//                        // Voting details
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Voting Results")
//                                .font(.headline)
//                            
//                            VStack(spacing: 8) {
//                                HStack {
//                                    Text("Most voted player:")
//                                        .foregroundColor(.secondary)
//                                    Spacer()
//                                    Text(votingResult.mostVotedPlayer)
//                                        .fontWeight(.semibold)
//                                }
//                                
//                                HStack {
//                                    Text("The spy was:")
//                                        .foregroundColor(.secondary)
//                                    Spacer()
//                                    Text(votingResult.spyName)
//                                        .fontWeight(.semibold)
//                                        .foregroundColor(.red)
//                                }
//                                
//                                // Spy guess section
//                                if let spyGuess = lobby.spyGuess {
//                                    HStack {
//                                        Text("Spy's guess:")
//                                            .foregroundColor(.secondary)
//                                        Spacer()
//                                        VStack(alignment: .trailing, spacing: 4) {
//                                            Text(spyGuess)
//                                                .fontWeight(.semibold)
//                                                .foregroundColor(.orange)
//                                            
//                                            if let spyGuessCorrect = votingResult.spyGuessCorrect {
//                                                HStack(spacing: 4) {
//                                                    Image(systemName: spyGuessCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
//                                                        .foregroundColor(spyGuessCorrect ? .green : .red)
//                                                    Text(spyGuessCorrect ? "Correct" : "Wrong")
//                                                        .font(.caption)
//                                                        .foregroundColor(spyGuessCorrect ? .green : .red)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical, 12)
//
//                        Divider()
//
//                        // Game details
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Game Details")
//                                .font(.headline)
//                            
//                            VStack(spacing: 8) {
//                                if let player = currentPlayer, player.role != .spy {
//                                    HStack {
//                                        Text("Location was:")
//                                            .foregroundColor(.secondary)
//                                        Spacer()
//                                        Text(lobby.location.name)
//                                            .fontWeight(.semibold)
//                                    }
//                                }
//                                
//                                HStack {
//                                    Text("Players:")
//                                        .foregroundColor(.secondary)
//                                    Spacer()
//                                    Text("\(lobby.players.count)")
//                                        .fontWeight(.semibold)
//                                }
//                            }
//                        }
//                        .padding(.vertical, 12)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .background(Color(.secondarySystemGroupedBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//            }
//            .padding()
//        }
//        .safeAreaInset(edge: .bottom) {
//            VStack(spacing: 12) {
//                if lobby.hostId == viewModel.currentUser?.uid {
//                    Button(action: {
//                        viewModel.restartGame()
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.clockwise")
//                            Text(NSLocalizedString("Back to Lobby", comment: ""))
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundColor(.reverse)
//                        .frame(maxWidth: .infinity, minHeight: 48)
//                        .background(Color.reverse2)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                } else {
//                    Text("Waiting for host to restart the game...")
//                        .font(.caption)
//                        .fontDesign(.monospaced)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.top, 10)
//            .padding(.bottom, 8)
//        }
//        .navigationTitle("Game Results")
//        .navigationBarTitleDisplayMode(.large)
//    }
    
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
    
    private func startRevealCountdown() {
        revealTimer?.invalidate()
        revealCountdown = 3
        revealTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if revealCountdown > 1 {
                revealCountdown -= 1
            } else {
                timer.invalidate()
                revealTimer = nil
                revealCountdown = 0
                // Show roles and start the main game timer
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingRole = true
                }
                startGameTimer(reset: true)
            }
        }
    }
    
    private func countdownView(lobby: GameLobby) -> some View {
        VStack(spacing: 24) {
            Text(NSLocalizedString("Get Ready!", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("\(max(revealCountdown, 1))")
                .font(.system(size: 96, weight: .bold))
                .foregroundColor(.blue)
                .transition(.scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct VotingView: View {
    let lobby: GameLobby
    @ObservedObject var viewModel: MultiplayerGameViewModel
    
    @State private var currentTime: TimeInterval = Date().timeIntervalSince1970
    @State private var timer: Timer? = nil
    @State private var showingSpyGuessAlert = false
    
    private var isCurrentPlayerSpy: Bool {
        guard let currentPlayer = lobby.players.first(where: { $0.name == viewModel.currentPlayerName }) else { return false }
        return currentPlayer.role == .spy
    }
    
    var body: some View {
        VStack() {
            Text("Voting Time!")
                .fontDesign(.rounded)
                .font(.largeTitle)
                .fontWeight(.black)
            
            Text("Who do you think is the spy?")
                .font(.title2)
                .foregroundColor(.secondary)
                .fontDesign(.monospaced)
                .multilineTextAlignment(.center)
            
            if let votingStartAt = lobby.votingStartAt,
               let votingDurationSeconds = lobby.votingDurationSeconds {
                let localNow = currentTime
                let serverNow = localNow + TimeInterval(Double(viewModel.serverTimeOffsetMs) / 1000.0)
                let elapsed = max(0, serverNow - votingStartAt)
                let remaining = max(0, Double(votingDurationSeconds) - elapsed)
                
                Spacer()
                HStack{
                    Image(systemName: "hourglass.circle.fill")
                    
                    Text("\(Int(remaining))s")
                    
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(remaining < 10 ? .red : .primary)
                }.font(.largeTitle)
                    .padding(.top)
                
                if remaining <= 0 {
                    Text("Time's up!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Players to vote for:")
                    .font(.headline)
                    .fontDesign(.rounded)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(lobby.players, id: \.name) { player in
                        if player.name != viewModel.currentPlayerName {
                            Button(action: {
                                viewModel.voteForPlayer(playerName: player.name)
                            }) {
                                VStack(spacing: 8) {
                                    HStack{
                                        Image(systemName: "person.crop.circle.fill")
                                        Spacer()
                                        Text(player.name)
                                        Spacer()
                                        
                                    }.font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    if viewModel.currentVote == player.name {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.reverse2)
                                            .font(.title2)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(Color.reverse2)
                                            .font(.title2)
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.currentVote == player.name ? Color.green.opacity(1) : Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(
                                    color: Color.reverse2,
                                    radius: 0,
                                    x: 2.5,
                                    y: 2
                                )
                            }
                            .disabled(viewModel.currentVote == player.name)
                        }
                    }
                }
                
                Spacer()
                
                if let currentVote = viewModel.currentVote {
                    Text("You voted for: \(currentVote)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            // Remove the manual "End Voting & Reveal" button
            // Voting will end automatically when:
            // 1. Time runs out
            // 2. Everyone has voted AND spy has made a guess
            
            Spacer()
            
        }
        .padding(.horizontal)
        .onAppear {
            currentTime = Date().timeIntervalSince1970
            startReliableTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert("Guess Submitted!", isPresented: $showingSpyGuessAlert) {
            Button("OK") { }
        } message: {
            Text("Your location guess has been submitted. Good luck!")
        }
        .overlay(
            // Always visible bottom sheet for spy
            Group {
                if isCurrentPlayerSpy {
                    VStack {
                        Spacer()
                        SpyGuessSheet(lobby: lobby, viewModel: viewModel, showingAlert: $showingSpyGuessAlert)
                    }
                }
            }
        )
    }
    
    // Remove the private checkVotingEndConditions function
    
    private func startReliableTimer() {
        // Stop any existing timer
        stopTimer()
        
        // Create a more reliable timer using DispatchQueue
        let queue = DispatchQueue.global(qos: .userInteractive)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                // Update current time
                self.currentTime = Date().timeIntervalSince1970
                
                // Check if voting should end automatically
                self.viewModel.checkVotingEndConditions()
            }
        }
        
        // Ensure timer runs even during scroll
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

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

// Extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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

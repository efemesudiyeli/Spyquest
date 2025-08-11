import SwiftUI
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
                        countdownView(room: room)
                    }
                case .voting:
                    VotingView(room: room, viewModel: viewModel)
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
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: viewModel.currentRoom?.status) { _, newStatus in
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
        .onChange(of: viewModel.currentRoom?.gameStartAt) { _, _ in
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: viewModel.serverTimeOffsetMs) { _, _ in
            syncTimerWithServerIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                syncTimerWithServerIfNeeded()
                if let room = viewModel.currentRoom, room.status == .playing, gameTimer == nil, showingRole {
                    startGameTimer(reset: false)
                }
            } else if newPhase == .background || newPhase == .inactive {
                // Optionally pause local timer to save resources; server sync will correct on resume
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
                        PlayerCard(
                            player: player,
                            isHost: player.name == room.hostName,
                            ready: room.readyPlayers?[player.name] ?? false
                        )
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.toggleReady()
                }) {
                    let isReady = room.readyPlayers?[viewModel.currentPlayerName] ?? false
                    HStack {
                        Image(systemName: isReady ? "hand.thumbsdown.fill" : "hand.thumbsup.fill")
                        Text(isReady ? NSLocalizedString("Unready", comment: "") : NSLocalizedString("Ready", comment: ""))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isReady ? Color.orange : Color.blue)
                    .cornerRadius(10)
                }
                
                if room.hostId == viewModel.currentUser?.uid {
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
                        .background((viewModel.areAllPlayersReady(in: room) && room.players.count >= 2) ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!(viewModel.areAllPlayersReady(in: room) && room.players.count >= 2))
                } else {
                    Text("Waiting for host to start the game...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
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
                    let nonHostReady = ready.filter { $0.key != room.hostName }
                    let readyCount = nonHostReady.values.filter { $0 }.count
                    let total = room.players.count
                    Text("\(readyCount + 1)/\(total) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    let total = room.players.filter { $0.name != room.hostName }.count
                    Text("0/\(total) ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                
                // Ready button for non-hosts
                if room.hostId != viewModel.currentUser?.uid {
                    Button(action: {
                        viewModel.markCurrentPlayerReady()
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
                            // Move status to playing; countdown will handle reveal and timer
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
        let nonHostPlayers = room.players.filter { $0.name != room.hostName }.map { $0.name }
        return nonHostPlayers.allSatisfy { ready[$0] == true }
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
            
            Spacer()
            
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
                        viewModel.endGameForAll()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
                if room.hostId == viewModel.currentUser?.uid {
                    HStack(spacing: 15) {
                        Button(NSLocalizedString("End Round For All", comment: "")) {
                            viewModel.startVoting()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
            
            
        }
        .padding()
    }
    
    private func gameEndView(room: GameRoom) -> some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let votingResult = room.votingResult {
                VStack(spacing: 15) {
                    Text("Voting Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Most voted player: \(votingResult.mostVotedPlayer)")
                        .font(.headline)
                    
                    // Show spy guess if available
                    if let spyGuess = room.spyGuess {
                        VStack(spacing: 8) {
                            Text("Spy's guess: \(spyGuess)")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            if let spyGuessCorrect = votingResult.spyGuessCorrect {
                                if spyGuessCorrect {
                                    Text("✅ Spy guessed correctly!")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                } else {
                                    Text("❌ Spy guessed incorrectly!")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Determine winner
                    let spyWins = votingResult.spyGuessCorrect == true
                    let playersWin = votingResult.spyCaught || votingResult.spyGuessCorrect == false
                    
                    if spyWins {
                        Text("🎭 SPY WINS!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    } else if playersWin {
                        Text("🎉 PLAYERS WIN!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    if votingResult.spyCaught {
                        Text("🎉 The spy was caught!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if !votingResult.spyCaught && votingResult.spyGuessCorrect != true {
                        Text("😱 The spy got away!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Text("The spy was: \(votingResult.spyName)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            
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
    
    private func countdownView(room: GameRoom) -> some View {
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
        guard let room = viewModel.currentRoom,
              room.status == .playing,
              let startAt = room.gameStartAt,
              let duration = room.gameDurationSeconds else { return }
        
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
    let room: GameRoom
    @ObservedObject var viewModel: MultiplayerGameViewModel
    
    @State private var currentTime: TimeInterval = Date().timeIntervalSince1970
    @State private var timer: Timer? = nil
    @State private var showingSpyGuessAlert = false
    
    private var isCurrentPlayerSpy: Bool {
        guard let currentPlayer = room.players.first(where: { $0.name == viewModel.currentPlayerName }) else { return false }
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
            
            if let votingStartAt = room.votingStartAt,
               let votingDurationSeconds = room.votingDurationSeconds {
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
                    ForEach(room.players, id: \.name) { player in
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
                        SpyGuessSheet(room: room, viewModel: viewModel, showingAlert: $showingSpyGuessAlert)
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
    let room: GameRoom
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
                            ForEach(room.selectedLocationSet.locations, id: \.id) { location in
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
            print("DEBUG: Current game location: \(room.location.nameKey)")
            print("DEBUG: Selected location set: \(room.selectedLocationSet.rawValue)")
            print("DEBUG: Available locations count: \(room.selectedLocationSet.locations.count)")
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

struct PlayerCard: View {
    let player: Player
    let isHost: Bool
    let ready: Bool
    
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
                
                Text(ready ? "Ready" : "Unready")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(ready ? .green : .blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
#Preview {
    VotingView(
        room: GameRoom(
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

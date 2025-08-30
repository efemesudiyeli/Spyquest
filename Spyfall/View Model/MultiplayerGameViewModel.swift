import Foundation
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

class MultiplayerGameViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var currentLobby: GameLobby?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentPlayerName: String = ""
    @Published var serverTimeOffsetMs: Int64 = 0
    @Published var currentVote: String? = nil
    @Published var isPremiumUser: Bool = false
    
    private var databaseRef = Database.database().reference()
    private var currentLobbyRef: DatabaseReference?
    private var connectionsRef: DatabaseReference?
    private var myConnectionRef: DatabaseReference?
    private var orphanSweepTimer: Timer?
    var gameViewModel: GameViewModel? // Reference to GameViewModel - made public for ad access
    
    init() {
        setupAuthStateListener()
        observeServerTimeOffset()
        loadPremiumStatus()
        startOrphanSweepTimer()
    }
    
    // MARK: - Premium Management
    
    func setGameViewModel(_ gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        // Sync premium status immediately
        syncPremiumStatus()
        
        // Listen for premium status changes
        gameViewModel.premiumStatusChanged = { [weak self] isPremium in
            DispatchQueue.main.async {
                self?.isPremiumUser = isPremium
                print("Premium status updated from GameViewModel: \(isPremium)")
            }
        }
    }
    
    private func syncPremiumStatus() {
        guard let gameViewModel = gameViewModel else { return }
        isPremiumUser = gameViewModel.isPremium
        print("Premium status synced: \(isPremiumUser)")
    }
    
    private func loadPremiumStatus() {
        // Try to get premium status from GameViewModel first
        if let gameViewModel = gameViewModel {
            isPremiumUser = gameViewModel.isPremium
            print("Premium status loaded from GameViewModel: \(isPremiumUser)")
        } else {
            // Fallback to UserDefaults if GameViewModel not available
            isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
            print("Premium status loaded from UserDefaults: \(isPremiumUser)")
        }
    }
    
    func setPremiumStatus(_ isPremium: Bool) {
        isPremiumUser = isPremium
        print("Premium status set to: \(isPremium)")
    }
    
    func createPlayerWithPremiumStatus(name: String, role: Role? = nil, playerLocationRole: String? = nil) -> Player {
        // Always check current premium status before creating player
        syncPremiumStatus()
        
        return Player(
            name: name,
            role: role,
            playerLocationRole: playerLocationRole,
            isPremium: isPremiumUser
        )
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    private func observeServerTimeOffset() {
        let offsetRef = Database.database().reference(withPath: ".info/serverTimeOffset")
        offsetRef.observe(.value) { [weak self] snapshot in
            guard let millis = snapshot.value as? Int64 else { return }
            DispatchQueue.main.async {
                self?.serverTimeOffsetMs = millis
            }
        }
    }
    
    func signInAnonymously() {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createGameLobby(playerCount: Int, playerName: String, selectedLocationSet: LocationSets, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { 
            completion(false)
            return 
        }
        
        isLoading = true
        errorMessage = ""
        
        // Use the selected location set to get random location
        let availableLocations = selectedLocationSet.locations
        print("DEBUG: Selected location set: \(selectedLocationSet.rawValue)")
        print("DEBUG: Available locations count: \(availableLocations.count)")
        
        let randomIndex = Int.random(in: 0..<availableLocations.count)
        let randomLocation = availableLocations[randomIndex]
        
        print("DEBUG: Selected random location: \(randomLocation.nameKey)")
        
        let lobbyCode = generateLobbyCode()
        var newLobby = GameLobby(
            id: lobbyCode,
            hostId: user.uid,
            hostName: playerName,
            location: randomLocation,
            maxPlayers: playerCount,
            players: [createPlayerWithPremiumStatus(name: playerName, role: .player)],
            status: .waiting,
            createdAt: Date(),
            selectedLocationSet: selectedLocationSet
        )
        // Initialize all players as unready (including host)
        newLobby.readyPlayers = [playerName: false]
        
        let lobbyData = newLobby.toDictionary()
        databaseRef.child("lobbys").child(lobbyCode).setValue(lobbyData) { [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.currentPlayerName = playerName
                    self?.currentLobby = newLobby
                    self?.currentLobbyRef = self?.databaseRef.child("lobbys").child(lobbyCode)
                    self?.setupPresence(lobbyCode: lobbyCode)
                    self?.observeLobbyChanges(lobbyCode: lobbyCode)
                    completion(true)
                }
            }
        }
    }
    
    func joinLobby(lobbyCode: String, playerName: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { 
            completion(false)
            return 
        }
        
        isLoading = true
        errorMessage = ""
        
        currentLobbyRef = databaseRef.child("lobbys").child(lobbyCode)
        currentLobbyRef?.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let lobbyData = snapshot.value as? [String: Any],
               let lobby = GameLobby.fromDictionary(lobbyData) {
                
                if lobby.players.count < lobby.maxPlayers && lobby.status == .waiting {
                    var updatedLobby = lobby
                    let newPlayer = self.createPlayerWithPremiumStatus(name: playerName, role: .player)
                    updatedLobby.players.append(newPlayer)
                    var updatedReady = lobby.readyPlayers ?? [:]
                    updatedReady[playerName] = false
                    updatedLobby.readyPlayers = updatedReady
                    
                    self.currentLobbyRef?.updateChildValues([
                        "players": updatedLobby.players.map { $0.toDictionary() },
                        "readyPlayers": updatedReady
                    ]) { error, _ in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                                completion(false)
                            } else {
                                self.currentPlayerName = playerName
                                self.currentLobby = updatedLobby
                                self.observeLobbyChanges(lobbyCode: lobbyCode)
                                self.setupPresence(lobbyCode: lobbyCode)
                                completion(true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Lobby is full or game has already started"
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Lobby not found"
                    completion(false)
                }
            }
        }
    }
    
    private func observeLobbyChanges(lobbyCode: String) {
        currentLobbyRef?.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let lobbyData = snapshot.value as? [String: Any] {
                if let lobby = GameLobby.fromDictionary(lobbyData) {
                    DispatchQueue.main.async {
                        self.currentLobby = lobby
                        
                        if lobby.players.isEmpty {
                            self.autoCloseEmptyLobby()
                        } else if lobby.status == .playing && lobby.players.count < 2 {
                            self.cancelGameDueToInsufficientPlayers()
                        } else if lobby.status == .playing || lobby.status == .revealing || lobby.status == .voting {
                            // If no active connections, remove lobby to avoid orphaned games
                            self.currentLobbyRef?.child("connections").observeSingleEvent(of: .value) { snapshot in
                                if !snapshot.exists() {
                                    self.currentLobbyRef?.removeValue()
                                }
                            }
                        }
                        
                        // Host-side cleanup: delete finished/cancelled lobbies after grace period
                        if lobby.hostId == self.currentUser?.uid,
                           (lobby.status == .finished || lobby.status == .cancelled),
                           let endedAt = lobby.statusEndedAt {
                            let localNow = Date().timeIntervalSince1970
                            let serverNow = localNow + TimeInterval(Double(self.serverTimeOffsetMs) / 1000.0)
                            let elapsed = serverNow - endedAt
                            let graceSeconds: TimeInterval = 5 * 60
                            if elapsed >= graceSeconds {
                                self.currentLobbyRef?.removeValue()
                            }
                        }
                    }
                } else {
                    // Log the parsing error for debugging
                    print("Failed to parse lobby data: \(lobbyData)")
                    
                    // Only auto-close if the lobby is actually deleted
                    if snapshot.exists() == false {
                        DispatchQueue.main.async {
                            self.autoCloseEmptyLobby()
                        }
                    }
                }
            } else {
                // Only auto-close if the lobby is actually deleted
                if snapshot.exists() == false {
                    DispatchQueue.main.async {
                        self.autoCloseEmptyLobby()
                    }
                }
            }
        }
    }
    
    private func autoCloseEmptyLobby() {
        currentLobbyRef?.removeValue()
        currentLobby = nil
        currentPlayerName = ""
        currentLobbyRef?.removeAllObservers()
        currentLobbyRef = nil
        teardownPresence()
    }
    
    private func cancelGameDueToInsufficientPlayers() {
        guard let lobby = currentLobby else { return }
        
        var updatedLobby = lobby
        updatedLobby.status = .cancelled
        
        currentLobbyRef?.updateChildValues([
            "status": "cancelled",
            "statusEndedAt": ServerValue.timestamp(),
            "players": updatedLobby.players.map { player in
                var updatedPlayer = player
                updatedPlayer.role = nil
                updatedPlayer.playerLocationRole = nil
                return updatedPlayer.toDictionary()
            }
        ])
        
        DispatchQueue.main.async {
            self.errorMessage = "Game cancelled: Not enough players to continue. Minimum 2 players required."
        }
    }
    
    func startGame() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        // Ensure everyone is ready before starting
        let allReady = areAllPlayersReady(in: lobby)
        guard allReady else { return }
        
        var updatedLobby = lobby
        updatedLobby.status = .revealing
        updatedLobby.assignRoles()
        
        currentLobbyRef?.updateChildValues([
            "status": "revealing",
            "statusEndedAt": NSNull(),
            "players": updatedLobby.players.map { $0.toDictionary() }
        ])
    }
    
    func startGamePlaying() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        currentLobbyRef?.updateChildValues([
            "status": "playing",
            "statusEndedAt": NSNull(),
            "gameStartAt": ServerValue.timestamp(),
            "gameDurationSeconds": Int(1 * 60)
        ])
    }
    
    func startVoting() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        currentLobbyRef?.updateChildValues([
            "status": "voting",
            "statusEndedAt": NSNull(),
            "votingStartAt": ServerValue.timestamp(),
            "votingDurationSeconds": 60,
            "votes": [:],
            "spyGuess": NSNull()
        ])
    }
    
    func voteForPlayer(playerName: String) {
        guard let lobby = currentLobby,
              lobby.status == .voting else { return }
        
        currentVote = playerName
        
        currentLobbyRef?.child("votes").child(currentPlayerName).setValue(playerName)
        
        // Check if majority has voted and reduce time to 10 seconds
        checkMajorityVoteAndReduceTime()
        
        // Check if we should end voting automatically
        checkAutoEndVoting()
    }
    
    private func checkMajorityVoteAndReduceTime() {
        guard let lobby = currentLobby,
              lobby.status == .voting else { return }
        
        // Get current votes count
        currentLobbyRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let votesData = snapshot.value as? [String: String] {
                let voteCount = votesData.count
                let totalPlayers = lobby.players.count
                let majorityThreshold = (totalPlayers / 2) + 1
                
                // If majority has voted AND spy submitted a choice (guess or opt-out), reduce voting time to 10 seconds
                if voteCount >= majorityThreshold, (self.currentLobby?.spyGuess != nil) {
                    self.currentLobbyRef?.updateChildValues([
                        "votingDurationSeconds": 10
                    ])
                }
            }
        }
    }
    
    func endVotingAndReveal() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        // Calculate voting results
        currentLobbyRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let votesData = snapshot.value as? [String: String] {
                let voteCounts = Dictionary(grouping: votesData.values, by: { $0 })
                    .mapValues { $0.count }
                
                let mostVotedPlayer = voteCounts.max(by: { $0.value < $1.value })?.key ?? "No one"
                let spyName = lobby.players.first(where: { $0.role == .spy })?.name ?? "Unknown"
                
                // Check if there's a tie (multiple players with same highest vote count)
                let maxVotes = voteCounts.values.max() ?? 0
                let playersWithMaxVotes = voteCounts.filter { $0.value == maxVotes }.keys
                let isTie = playersWithMaxVotes.count > 1
                
                // Check if spy was caught (spy is among the most voted players)
                let spyCaught = playersWithMaxVotes.contains(spyName)
                
                // Check if spy made a correct guess
                let spyGuessCorrect: Bool?
                if let spyGuess = lobby.spyGuess, !spyGuess.isEmpty {
                    spyGuessCorrect = spyGuess.lowercased() == lobby.location.nameKey.lowercased()
                } else {
                    spyGuessCorrect = nil
                }
                
                // Determine winner based on game rules
                print("DEBUG: Voting Results - Spy: \(spyName), Most Voted: \(mostVotedPlayer)")
                print("DEBUG: Spy Caught: \(spyCaught), Is Tie: \(isTie)")
                print("DEBUG: Spy Guess: \(lobby.spyGuess ?? "nil"), Correct: \(spyGuessCorrect?.description ?? "nil")")
                
                let spyWins: Bool
                
                if isTie {
                    // Tie scenarios:
                    if spyGuessCorrect == true {
                        // Rule 2: Tie + Spy guesses correctly → Spy wins
                        spyWins = true
                    } else if spyGuessCorrect == false {
                        // Rule 3: Tie + Spy guesses incorrectly → Players win
                        spyWins = false
                    } else {
                        // Rule 1: Tie + No spy guess → Spy wins
                        spyWins = true
                    }
                } else {
                    // No tie scenarios:
                    if spyCaught {
                        if spyGuessCorrect == true {
                            // Rule 4: Spy caught + correct guess → Spy wins
                            spyWins = true
                        } else {
                            // Rule 5: Spy caught + incorrect guess → Players win
                            // Rule 6: Spy caught + no guess → Players win
                            spyWins = false
                        }
                    } else {
                        // Spy not caught
                        if spyGuessCorrect == true {
                            // Spy not caught + correct guess → Spy wins
                            spyWins = true
                        } else if spyGuessCorrect == false {
                            // Spy not caught + incorrect guess → Players win
                            spyWins = false
                        } else {
                            // Spy not caught + no guess → Spy wins (spy successfully hid)
                            spyWins = true
                        }
                    }
                }
                
                print("DEBUG: Final Result - Spy Wins: \(spyWins)")
                
                let votingResult = VotingResult(
                    mostVotedPlayer: mostVotedPlayer,
                    spyName: spyName,
                    spyCaught: spyCaught,
                    voteCounts: voteCounts,
                    spyGuessCorrect: spyGuessCorrect,
                    isTie: isTie,
                    spyWins: spyWins
                )
                
                self.currentLobbyRef?.updateChildValues([
                    "status": "finished",
                    "statusEndedAt": ServerValue.timestamp(),
                    "votingResult": votingResult.toDictionary()
                ])
            }
        }
    }
    
    func tryStartIfAllReady() {
        guard let lobby = currentLobby else { return }
        let ready = lobby.readyPlayers ?? [:]
        let nonHostPlayers = lobby.players.filter { $0.name != lobby.hostName }.map { $0.name }
        let allReady = nonHostPlayers.allSatisfy { ready[$0] == true }
        if allReady {
            currentLobbyRef?.updateChildValues([
                "status": "playing"
            ])
        }
    }
    
    func restartGame() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        // Select a new random location
        let availableLocations = lobby.selectedLocationSet.locations
        let randomIndex = Int.random(in: 0..<availableLocations.count)
        let newLocation = availableLocations[randomIndex]
        
        print("DEBUG: RestartGame - Selected new location: \(newLocation.nameKey)")
        print("DEBUG: RestartGame - New location roles: \(newLocation.roles)")
        
        var updatedLobby = lobby
        updatedLobby.location = newLocation  // Update the location in the lobby
        updatedLobby.status = .revealing
        updatedLobby.readyPlayers = nil
        
        // Reset all player roles and assign new ones
        for index in updatedLobby.players.indices {
            updatedLobby.players[index].role = nil
            updatedLobby.players[index].playerLocationRole = nil
        }
        
        // Assign new roles
        updatedLobby.assignRoles()
        
        // Update local state immediately for better UX
        DispatchQueue.main.async {
            self.currentLobby = updatedLobby
        }
        
        // Update Firebase for synchronization
        currentLobbyRef?.updateChildValues([
            "status": "revealing",
            "location": newLocation.toDictionary(),
            "players": updatedLobby.players.map { $0.toDictionary() },
            "readyPlayers": NSNull(),
            "gameStartAt": NSNull(),
            "gameDurationSeconds": NSNull(),
            "votingStartAt": NSNull(),
            "votingDurationSeconds": NSNull(),
            "votes": NSNull(),
            "votingResult": NSNull(),
            "spyGuess": NSNull(),
            "statusEndedAt": NSNull()
        ])
    }
    
    func toggleReady() {
        guard var lobby = currentLobby else { return }
        var ready = lobby.readyPlayers ?? [:]
        let current = ready[currentPlayerName] ?? false
        ready[currentPlayerName] = !current
        lobby.readyPlayers = ready
        DispatchQueue.main.async {
            self.currentLobby = lobby
        }
        currentLobbyRef?.updateChildValues([
            "readyPlayers": ready
        ])
    }
    
    func markCurrentPlayerReady() {
        guard var lobby = currentLobby else { return }
        var ready = lobby.readyPlayers ?? [:]
        ready[currentPlayerName] = true
        lobby.readyPlayers = ready
        DispatchQueue.main.async {
            self.currentLobby = lobby
        }
        currentLobbyRef?.updateChildValues([
            "readyPlayers": ready
        ])
    }
    
    func leaveLobby() {
        guard let lobby = currentLobby,
              let user = currentUser else { return }
        
        var updatedPlayers = lobby.players
        updatedPlayers.removeAll { $0.name == currentPlayerName }
        var updatedReady = lobby.readyPlayers ?? [:]
        updatedReady.removeValue(forKey: currentPlayerName)
        
        if updatedPlayers.isEmpty {
            currentLobbyRef?.removeValue()
        } else {
            currentLobbyRef?.updateChildValues([
                "players": updatedPlayers.map { $0.toDictionary() },
                "readyPlayers": updatedReady
            ])
        }
        
        // Clear local state without showing any error message
        currentLobby = nil
        currentPlayerName = ""
        currentLobbyRef?.removeAllObservers()
        currentLobbyRef = nil
        teardownPresence()
    }
    
    func returnToLobbyForAll() {
        guard let lobby = currentLobby,
              lobby.hostId == currentUser?.uid else { return }
        
        // Reset all game state and return to waiting lobby
        var updatedLobby = lobby
        updatedLobby.status = .waiting
        updatedLobby.readyPlayers = nil
        
        // Reset all player roles and game data
        for index in updatedLobby.players.indices {
            updatedLobby.players[index].role = nil
            updatedLobby.players[index].playerLocationRole = nil
        }
        
        // Update local state immediately for better UX
        DispatchQueue.main.async {
            self.currentLobby = updatedLobby
        }
        
        // Update Firebase for synchronization - return everyone to waiting lobby
        currentLobbyRef?.updateChildValues([
            "status": "waiting",
            "players": updatedLobby.players.map { $0.toDictionary() },
            "readyPlayers": NSNull(),
            "gameStartAt": NSNull(),
            "gameDurationSeconds": NSNull(),
            "votingStartAt": NSNull(),
            "votingDurationSeconds": NSNull(),
            "votes": NSNull(),
            "votingResult": NSNull(),
            "spyGuess": NSNull(),
            "statusEndedAt": NSNull()
        ])
    }
    
    func endGameForAll() {
        guard let lobby = currentLobby else { return }
        currentLobbyRef?.updateChildValues([
            "status": "finished",
            "statusEndedAt": ServerValue.timestamp()
        ])
    }
    
    func makeSpyGuess(guess: String) {
        guard let lobby = currentLobby,
              lobby.status == .voting,
              let currentPlayer = lobby.players.first(where: { $0.name == currentPlayerName }),
              currentPlayer.role == .spy else { return }
        
        // Update spy guess in Firebase
        currentLobbyRef?.updateChildValues([
            "spyGuess": guess
        ])
        
        // Check if we should end voting automatically
        checkAutoEndVoting()
    }
    
    // Spy explicitly chooses not to guess any location
    func spyOptOutGuess() {
        guard let lobby = currentLobby,
              lobby.status == .voting,
              let currentPlayer = lobby.players.first(where: { $0.name == currentPlayerName }),
              currentPlayer.role == .spy else { return }
        
        currentLobbyRef?.updateChildValues([
            "spyGuess": ""
        ])
        
        checkAutoEndVoting()
    }
    
    private func checkAutoEndVoting() {
        guard let lobby = currentLobby,
              lobby.status == .voting else { return }
        
        // Get current votes count
        currentLobbyRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let votesData = snapshot.value as? [String: String] {
                let voteCount = votesData.count
                let totalPlayers = lobby.players.count
                
                // If everyone has voted and spy has submitted a choice (guess or opt-out), end voting automatically
                if voteCount >= totalPlayers && (self.currentLobby?.spyGuess != nil) && lobby.hostId == self.currentUser?.uid {
                    print("DEBUG: Auto-ending voting - everyone has voted and spy submitted choice")
                    self.endVotingAndReveal()
                }
            }
        }
    }
    
    // Public function for VotingView to check voting end conditions
    func checkVotingEndConditions() {
        guard let lobby = currentLobby,
              lobby.status == .voting else { return }
        
        let localNow = Date().timeIntervalSince1970
        let serverNow = localNow + TimeInterval(Double(serverTimeOffsetMs) / 1000.0)
        
        // Check if voting time is up
        if let votingStartAt = lobby.votingStartAt,
           let votingDurationSeconds = lobby.votingDurationSeconds {
            let elapsed = max(0, serverNow - votingStartAt)
            let remaining = max(0, Double(votingDurationSeconds) - elapsed)
            
            if remaining <= 0 && lobby.hostId == currentUser?.uid {
                print("DEBUG: Voting time is up, ending voting automatically")
                endVotingAndReveal()
                return
            }
        }
        
        // Check if everyone has voted and spy submitted a choice (guess or opt-out)
        if lobby.spyGuess != nil {
            currentLobbyRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                
                if let votesData = snapshot.value as? [String: String] {
                    let voteCount = votesData.count
                    let totalPlayers = lobby.players.count
                    
                    // If everyone has voted (including spy), end voting
                    if voteCount >= totalPlayers && lobby.hostId == self.currentUser?.uid {
                        print("DEBUG: Everyone has voted and spy submitted choice, ending voting automatically")
                        self.endVotingAndReveal()
                    }
                }
            }
        }
    }
    
    private func generateLobbyCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        var code = ""
        
        for _ in 0..<3 {
            code += String(letters.randomElement()!)
        }
        for _ in 0..<3 {
            code += String(numbers.randomElement()!)
        }
        
        return code
    }
    
    func areAllPlayersReady(in lobby: GameLobby) -> Bool {
        let ready = lobby.readyPlayers ?? [:]
        let allPlayerNames = lobby.players.map { $0.name }
        return !allPlayerNames.isEmpty && allPlayerNames.allSatisfy { ready[$0] == true }
    }
}

// MARK: - Presence Tracking
extension MultiplayerGameViewModel {
    private func setupPresence(lobbyCode: String) {
        guard !currentPlayerName.isEmpty else { return }
        connectionsRef = databaseRef.child("lobbys").child(lobbyCode).child("connections")
        myConnectionRef = connectionsRef?.child(currentPlayerName)
        // Mark online
        myConnectionRef?.setValue(true)
        // Ensure removal when app disconnects unexpectedly
        myConnectionRef?.onDisconnectRemoveValue()
        // Optionally track lastSeen
        let lastSeenRef = databaseRef.child("lobbys").child(lobbyCode).child("lastSeen").child(currentPlayerName)
        lastSeenRef.setValue(ServerValue.timestamp())
        lastSeenRef.onDisconnectSetValue(ServerValue.timestamp())
    }
    
    private func teardownPresence() {
        myConnectionRef?.removeValue()
        myConnectionRef = nil
        connectionsRef = nil
    }
}

// MARK: - Orphan Lobby Sweeper (client-side, no Cloud Functions)
extension MultiplayerGameViewModel {
    private func startOrphanSweepTimer() {
        stopOrphanSweepTimer()
        orphanSweepTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.performOrphanSweep()
        }
        if let orphanSweepTimer = orphanSweepTimer {
            RunLoop.main.add(orphanSweepTimer, forMode: .common)
        }
    }
    
    private func stopOrphanSweepTimer() {
        orphanSweepTimer?.invalidate()
        orphanSweepTimer = nil
    }
    
    private func performOrphanSweep() {
        guard let userId = currentUser?.uid else { return }
        let lobbysRef = databaseRef.child("lobbys")
        lobbysRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            let localNow = Date().timeIntervalSince1970
            let serverNow = localNow + TimeInterval(Double(self.serverTimeOffsetMs) / 1000.0)
            let graceSeconds: TimeInterval = 5 * 60
            
            var deletions: [DatabaseReference] = []
            for child in snapshot.children {
                guard let lobbySnap = child as? DataSnapshot,
                      let dict = lobbySnap.value as? [String: Any],
                      let lobby = GameLobby.fromDictionary(dict) else { continue }
                
                // Only sweep lobbies owned by this user (host-based sweep)
                guard lobby.hostId == userId else { continue }
                
                // If active status and no connections → delete
                if lobby.status == .revealing || lobby.status == .playing || lobby.status == .voting {
                    let connectionsExists = lobbySnap.childSnapshot(forPath: "connections").exists()
                    if connectionsExists == false {
                        deletions.append(lobbySnap.ref)
                        continue
                    }
                }
                
                // If finished/cancelled and grace exceeded → delete
                if (lobby.status == .finished || lobby.status == .cancelled), let endedAt = lobby.statusEndedAt {
                    if serverNow - endedAt >= graceSeconds {
                        deletions.append(lobbySnap.ref)
                        continue
                    }
                }
            }
            // Execute deletions
            for ref in deletions { ref.removeValue() }
        }
    }
}

struct GameLobby: Identifiable, Codable {
    let id: String
    let hostId: String
    let hostName: String
    var location: Location
    let maxPlayers: Int
    var players: [Player]
    var status: GameStatus
    let createdAt: Date
    var readyPlayers: [String: Bool]? = nil
    var gameStartAt: TimeInterval? = nil
    var gameDurationSeconds: Int? = nil
    var votingStartAt: TimeInterval? = nil
    var votingDurationSeconds: Int? = nil
    var votes: [String: String]? = nil
    var votingResult: VotingResult? = nil
    var spyGuess: String? = nil
    var statusEndedAt: TimeInterval? = nil
    var selectedLocationSet: LocationSets
    
    enum GameStatus: String, Codable, CaseIterable {
        case waiting = "waiting"
        case revealing = "revealing"
        case playing = "playing"
        case voting = "voting"
        case finished = "finished"
        case cancelled = "cancelled"
    }
    
    mutating func assignRoles() {
        let spyIndex = Int.random(in: 0..<players.count)
        
        print("DEBUG: Assigning roles for location: \(location.nameKey)")
        print("DEBUG: Available roles: \(location.roles)")
        print("DEBUG: Localized roles: \(location.localizedRoles)")
        
        for index in players.indices {
            if index == spyIndex {
                players[index].role = .spy
                print("DEBUG: Player \(players[index].name) assigned as SPY")
            } else {
                players[index].role = .player
                let assignedRole = location.roles.randomElement()
                players[index].playerLocationRole = assignedRole
                print("DEBUG: Player \(players[index].name) assigned role: \(assignedRole ?? "nil")")
            }
        }
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "hostId": hostId,
            "hostName": hostName,
            "location": location.toDictionary(),
            "maxPlayers": maxPlayers,
            "players": players.map { $0.toDictionary() },
            "status": status.rawValue,
            "createdAt": createdAt.timeIntervalSince1970,
            "selectedLocationSet": selectedLocationSet.rawValue
        ]
        if let readyPlayers = readyPlayers {
            dict["readyPlayers"] = readyPlayers
        }
        if let gameStartAt = gameStartAt {
            dict["gameStartAt"] = gameStartAt
        }
        if let gameDurationSeconds = gameDurationSeconds {
            dict["gameDurationSeconds"] = gameDurationSeconds
        }
        if let votingStartAt = votingStartAt {
            dict["votingStartAt"] = votingStartAt
        }
        if let votingDurationSeconds = votingDurationSeconds {
            dict["votingDurationSeconds"] = votingDurationSeconds
        }
        if let votes = votes {
            dict["votes"] = votes
        }
        if let votingResult = votingResult {
            dict["votingResult"] = votingResult.toDictionary()
        }
        if let spyGuess = spyGuess {
            dict["spyGuess"] = spyGuess
        }
        if let statusEndedAt = statusEndedAt {
            dict["statusEndedAt"] = statusEndedAt
        }
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> GameLobby? {
        guard let id = dict["id"] as? String,
              let hostId = dict["hostId"] as? String,
              let hostName = dict["hostName"] as? String,
              let locationDict = dict["location"] as? [String: Any],
              let location = Location.fromDictionary(locationDict),
              let maxPlayers = dict["maxPlayers"] as? Int,
              let playersArray = dict["players"] as? [[String: Any]],
              let statusString = dict["status"] as? String,
              let status = GameStatus(rawValue: statusString),
              let createdAtInterval = dict["createdAt"] as? TimeInterval,
              let selectedLocationSetRaw = dict["selectedLocationSet"] as? String,
              let selectedLocationSet = LocationSets(rawValue: selectedLocationSetRaw) else {
            return nil
        }
        
        let players = playersArray.compactMap { Player.fromDictionary($0) }
        let createdAt = Date(timeIntervalSince1970: createdAtInterval)
        var lobby = GameLobby(
            id: id,
            hostId: hostId,
            hostName: hostName,
            location: location,
            maxPlayers: maxPlayers,
            players: players,
            status: status,
            createdAt: createdAt,
            selectedLocationSet: selectedLocationSet
        )
        if let ready = dict["readyPlayers"] as? [String: Bool] {
            lobby.readyPlayers = ready
        }
        if let gameStartAt = dict["gameStartAt"] as? TimeInterval {
            lobby.gameStartAt = gameStartAt / ((gameStartAt > 1000000000000) ? 1000.0 : 1.0)
        }
        if let duration = dict["gameDurationSeconds"] as? Int {
            lobby.gameDurationSeconds = duration
        }
        if let votingStartAt = dict["votingStartAt"] as? TimeInterval {
            lobby.votingStartAt = votingStartAt / ((votingStartAt > 1000000000000) ? 1000.0 : 1.0)
        }
        if let votingDuration = dict["votingDurationSeconds"] as? Int {
            lobby.votingDurationSeconds = votingDuration
        }
        if let votes = dict["votes"] as? [String: String] {
            lobby.votes = votes
        }
        if let votingResultDict = dict["votingResult"] as? [String: Any] {
            lobby.votingResult = VotingResult.fromDictionary(votingResultDict)
        }
        if let spyGuess = dict["spyGuess"] as? String {
            lobby.spyGuess = spyGuess
        }
        if let statusEndedAt = dict["statusEndedAt"] as? TimeInterval {
            lobby.statusEndedAt = statusEndedAt / ((statusEndedAt > 1000000000000) ? 1000.0 : 1.0)
        }
        return lobby
    }
}

struct VotingResult: Codable {
    let mostVotedPlayer: String
    let spyName: String
    let spyCaught: Bool
    let voteCounts: [String: Int]
    let spyGuessCorrect: Bool?
    let isTie: Bool
    let spyWins: Bool
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "mostVotedPlayer": mostVotedPlayer,
            "spyName": spyName,
            "spyCaught": spyCaught,
            "voteCounts": voteCounts
        ]
        if let spyGuessCorrect = spyGuessCorrect {
            dict["spyGuessCorrect"] = spyGuessCorrect
        }
        dict["isTie"] = isTie
        dict["spyWins"] = spyWins
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> VotingResult? {
        guard let mostVotedPlayer = dict["mostVotedPlayer"] as? String,
              let spyName = dict["spyName"] as? String,
              let spyCaught = dict["spyCaught"] as? Bool,
              let voteCounts = dict["voteCounts"] as? [String: Int] else {
            return nil
        }
        
        let spyGuessCorrect = dict["spyGuessCorrect"] as? Bool
        let isTie = dict["isTie"] as? Bool ?? false
        let spyWins = dict["spyWins"] as? Bool ?? false
        
        return VotingResult(
            mostVotedPlayer: mostVotedPlayer,
            spyName: spyName,
            spyCaught: spyCaught,
            voteCounts: voteCounts,
            spyGuessCorrect: spyGuessCorrect,
            isTie: isTie,
            spyWins: spyWins
        )
    }
}

extension Location {
    func toDictionary() -> [String: Any] {
        return [
            "nameKey": nameKey,
            "roles": roles
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Location? {
        guard let nameKey = dict["nameKey"] as? String,
              let roles = dict["roles"] as? [String] else {
            return nil
        }
        
        return Location(nameKey: nameKey, roles: roles)
    }
}

extension Player {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "isPremium": isPremium
        ]
        
        if let role = role {
            dict["role"] = role.rawValue
        }
        
        if let playerLocationRole = playerLocationRole {
            dict["playerLocationRole"] = playerLocationRole
        }
        
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Player? {
        guard let name = dict["name"] as? String else {
            return nil
        }
        
        let role: Role?
        if let roleString = dict["role"] as? String {
            role = Role(rawValue: roleString)
        } else {
            role = nil
        }
        
        let playerLocationRole = dict["playerLocationRole"] as? String
        let isPremium = dict["isPremium"] as? Bool ?? false
        
        var player = Player(name: name, role: role, isPremium: isPremium)
        player.playerLocationRole = playerLocationRole
        
        return player
    }
}

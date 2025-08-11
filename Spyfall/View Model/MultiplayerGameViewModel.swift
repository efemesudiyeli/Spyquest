import Foundation
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

class MultiplayerGameViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var currentRoom: GameRoom?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentPlayerName: String = ""
    @Published var serverTimeOffsetMs: Int64 = 0
    @Published var currentVote: String? = nil
    
    private var databaseRef = Database.database().reference()
    private var currentRoomRef: DatabaseReference?
    
    init() {
        setupAuthStateListener()
        observeServerTimeOffset()
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
    
    func createGameRoom(playerCount: Int, playerName: String, selectedLocationSet: LocationSets, completion: @escaping (Bool) -> Void) {
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
        
        let roomCode = generateRoomCode()
        var newRoom = GameRoom(
            id: roomCode,
            hostId: user.uid,
            hostName: playerName,
            location: randomLocation,
            maxPlayers: playerCount,
            players: [Player(name: playerName, role: .player)],
            status: .waiting,
            createdAt: Date(),
            selectedLocationSet: selectedLocationSet
        )
        // Initialize all players as unready (including host)
        newRoom.readyPlayers = [playerName: false]
        
        let roomData = newRoom.toDictionary()
        databaseRef.child("rooms").child(roomCode).setValue(roomData) { [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.currentPlayerName = playerName
                    self?.currentRoom = newRoom
                    self?.currentRoomRef = self?.databaseRef.child("rooms").child(roomCode)
                    self?.observeRoomChanges(roomCode: roomCode)
                    completion(true)
                }
            }
        }
    }
    
    func joinRoom(roomCode: String, playerName: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { 
            completion(false)
            return 
        }
        
        isLoading = true
        errorMessage = ""
        
        currentRoomRef = databaseRef.child("rooms").child(roomCode)
        currentRoomRef?.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let roomData = snapshot.value as? [String: Any],
               let room = GameRoom.fromDictionary(roomData) {
                
                if room.players.count < room.maxPlayers && room.status == .waiting {
                    var updatedRoom = room
                    let newPlayer = Player(name: playerName, role: .player)
                    updatedRoom.players.append(newPlayer)
                    var updatedReady = room.readyPlayers ?? [:]
                    updatedReady[playerName] = false
                    updatedRoom.readyPlayers = updatedReady
                    
                    self.currentRoomRef?.updateChildValues([
                        "players": updatedRoom.players.map { $0.toDictionary() },
                        "readyPlayers": updatedReady
                    ]) { error, _ in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                                completion(false)
                            } else {
                                self.currentPlayerName = playerName
                                self.currentRoom = updatedRoom
                                self.observeRoomChanges(roomCode: roomCode)
                                completion(true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Room is full or game has already started"
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Room not found"
                    completion(false)
                }
            }
        }
    }
    
    private func observeRoomChanges(roomCode: String) {
        currentRoomRef?.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let roomData = snapshot.value as? [String: Any] {
                if let room = GameRoom.fromDictionary(roomData) {
                    DispatchQueue.main.async {
                        self.currentRoom = room
                        
                        if room.players.isEmpty {
                            self.autoCloseEmptyRoom()
                        } else if room.status == .playing && room.players.count < 2 {
                            self.cancelGameDueToInsufficientPlayers()
                        }
                    }
                } else {
                    // Log the parsing error for debugging
                    print("Failed to parse room data: \(roomData)")
                    
                    // Only auto-close if the room is actually deleted
                    if snapshot.exists() == false {
                        DispatchQueue.main.async {
                            self.autoCloseEmptyRoom()
                        }
                    }
                }
            } else {
                // Only auto-close if the room is actually deleted
                if snapshot.exists() == false {
                    DispatchQueue.main.async {
                        self.autoCloseEmptyRoom()
                    }
                }
            }
        }
    }
    
    private func autoCloseEmptyRoom() {
        currentRoomRef?.removeValue()
        currentRoom = nil
        currentPlayerName = ""
        currentRoomRef?.removeAllObservers()
        currentRoomRef = nil
    }
    
    private func cancelGameDueToInsufficientPlayers() {
        guard let room = currentRoom else { return }
        
        var updatedRoom = room
        updatedRoom.status = .cancelled
        
        currentRoomRef?.updateChildValues([
            "status": "cancelled",
            "players": updatedRoom.players.map { player in
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
        guard let room = currentRoom,
              room.hostId == currentUser?.uid else { return }
        
        // Ensure everyone is ready before starting
        let allReady = areAllPlayersReady(in: room)
        guard allReady else { return }
        
        var updatedRoom = room
        updatedRoom.status = .playing
        updatedRoom.assignRoles()
        
        currentRoomRef?.updateChildValues([
            "status": "playing",
            "players": updatedRoom.players.map { $0.toDictionary() },
            "gameStartAt": ServerValue.timestamp(),
            "gameDurationSeconds": Int(8.5 * 60)
        ])
    }
    
    func startVoting() {
        guard let room = currentRoom,
              room.hostId == currentUser?.uid else { return }
        
        currentRoomRef?.updateChildValues([
            "status": "voting",
            "votingStartAt": ServerValue.timestamp(),
            "votingDurationSeconds": 60,
            "votes": [:]
        ])
    }
    
    func voteForPlayer(playerName: String) {
        guard let room = currentRoom,
              room.status == .voting else { return }
        
        currentVote = playerName
        
        currentRoomRef?.child("votes").child(currentPlayerName).setValue(playerName)
        
        // Check if majority has voted and reduce time to 10 seconds
        checkMajorityVoteAndReduceTime()
    }
    
    private func checkMajorityVoteAndReduceTime() {
        guard let room = currentRoom,
              room.status == .voting else { return }
        
        // Get current votes count
        currentRoomRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let votesData = snapshot.value as? [String: String] {
                let voteCount = votesData.count
                let totalPlayers = room.players.count
                let majorityThreshold = (totalPlayers / 2) + 1
                
                // If majority has voted, reduce voting time to 10 seconds
                if voteCount >= majorityThreshold {
                    self.currentRoomRef?.updateChildValues([
                        "votingDurationSeconds": 10
                    ])
                }
            }
        }
    }
    
    func endVotingAndReveal() {
        guard let room = currentRoom,
              room.hostId == currentUser?.uid else { return }
        
        // Calculate voting results
        currentRoomRef?.child("votes").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let votesData = snapshot.value as? [String: String] {
                let voteCounts = Dictionary(grouping: votesData.values, by: { $0 })
                    .mapValues { $0.count }
                
                let mostVotedPlayer = voteCounts.max(by: { $0.value < $1.value })?.key ?? "No one"
                let spyName = room.players.first(where: { $0.role == .spy })?.name ?? "Unknown"
                let spyCaught = mostVotedPlayer == spyName
                
                // Check if spy made a correct guess
                let spyGuessCorrect: Bool?
                if let spyGuess = room.spyGuess {
                    spyGuessCorrect = spyGuess.lowercased() == room.location.nameKey.lowercased()
                } else {
                    spyGuessCorrect = nil
                }
                
                let votingResult = VotingResult(
                    mostVotedPlayer: mostVotedPlayer,
                    spyName: spyName,
                    spyCaught: spyCaught,
                    voteCounts: voteCounts,
                    spyGuessCorrect: spyGuessCorrect
                )
                
                self.currentRoomRef?.updateChildValues([
                    "status": "finished",
                    "votingResult": votingResult.toDictionary()
                ])
            }
        }
    }
    
    func tryStartIfAllReady() {
        guard let room = currentRoom else { return }
        let ready = room.readyPlayers ?? [:]
        let nonHostPlayers = room.players.filter { $0.name != room.hostName }.map { $0.name }
        let allReady = nonHostPlayers.allSatisfy { ready[$0] == true }
        if allReady {
            currentRoomRef?.updateChildValues([
                "status": "playing"
            ])
        }
    }
    
    func restartGame() {
        guard let room = currentRoom,
              room.hostId == currentUser?.uid else { return }
        
        var updatedRoom = room
        updatedRoom.status = .waiting
        updatedRoom.readyPlayers = nil
        
        // Reset all player roles
        for index in updatedRoom.players.indices {
            updatedRoom.players[index].role = nil
            updatedRoom.players[index].playerLocationRole = nil
        }
        
        // Update local state immediately for better UX
        DispatchQueue.main.async {
            self.currentRoom = updatedRoom
        }
        
        // Update Firebase for synchronization
        currentRoomRef?.updateChildValues([
            "status": "waiting",
            "players": updatedRoom.players.map { $0.toDictionary() },
            "readyPlayers": NSNull(),
            "gameStartAt": NSNull(),
            "gameDurationSeconds": NSNull(),
            "votingStartAt": NSNull(),
            "votingDurationSeconds": NSNull(),
            "votes": NSNull(),
            "votingResult": NSNull(),
            "spyGuess": NSNull()
        ])
    }
    
    func toggleReady() {
        guard var room = currentRoom else { return }
        var ready = room.readyPlayers ?? [:]
        let current = ready[currentPlayerName] ?? false
        ready[currentPlayerName] = !current
        room.readyPlayers = ready
        DispatchQueue.main.async {
            self.currentRoom = room
        }
        currentRoomRef?.updateChildValues([
            "readyPlayers": ready
        ])
    }
    
    func markCurrentPlayerReady() {
        guard var room = currentRoom else { return }
        var ready = room.readyPlayers ?? [:]
        ready[currentPlayerName] = true
        room.readyPlayers = ready
        DispatchQueue.main.async {
            self.currentRoom = room
        }
        currentRoomRef?.updateChildValues([
            "readyPlayers": ready
        ])
    }
    
    func leaveRoom() {
        guard let room = currentRoom,
              let user = currentUser else { return }
        
        var updatedPlayers = room.players
        updatedPlayers.removeAll { $0.name == currentPlayerName }
        var updatedReady = room.readyPlayers ?? [:]
        updatedReady.removeValue(forKey: currentPlayerName)
        
        if updatedPlayers.isEmpty {
            currentRoomRef?.removeValue()
        } else {
            currentRoomRef?.updateChildValues([
                "players": updatedPlayers.map { $0.toDictionary() },
                "readyPlayers": updatedReady
            ])
        }
        
        // Clear local state without showing any error message
        currentRoom = nil
        currentPlayerName = ""
        currentRoomRef?.removeAllObservers()
        currentRoomRef = nil
    }
    
    func endGameForAll() {
        guard let room = currentRoom else { return }
        currentRoomRef?.updateChildValues([
            "status": "finished"
        ])
    }
    
    func makeSpyGuess(guess: String) {
        guard let room = currentRoom,
              room.status == .voting,
              let currentPlayer = room.players.first(where: { $0.name == currentPlayerName }),
              currentPlayer.role == .spy else { return }
        
        // Update spy guess in Firebase
        currentRoomRef?.updateChildValues([
            "spyGuess": guess
        ])
    }
    
    private func generateRoomCode() -> String {
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
    
    func areAllPlayersReady(in room: GameRoom) -> Bool {
        let ready = room.readyPlayers ?? [:]
        let allPlayerNames = room.players.map { $0.name }
        return !allPlayerNames.isEmpty && allPlayerNames.allSatisfy { ready[$0] == true }
    }
}

struct GameRoom: Identifiable, Codable {
    let id: String
    let hostId: String
    let hostName: String
    let location: Location
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
        
        for index in players.indices {
            if index == spyIndex {
                players[index].role = .spy
            } else {
                players[index].role = .player
                players[index].playerLocationRole = location.roles.randomElement()
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
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> GameRoom? {
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
        var room = GameRoom(
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
            room.readyPlayers = ready
        }
        if let gameStartAt = dict["gameStartAt"] as? TimeInterval {
            room.gameStartAt = gameStartAt / ((gameStartAt > 1000000000000) ? 1000.0 : 1.0)
        }
        if let duration = dict["gameDurationSeconds"] as? Int {
            room.gameDurationSeconds = duration
        }
        if let votingStartAt = dict["votingStartAt"] as? TimeInterval {
            room.votingStartAt = votingStartAt / ((votingStartAt > 1000000000000) ? 1000.0 : 1.0)
        }
        if let votingDuration = dict["votingDurationSeconds"] as? Int {
            room.votingDurationSeconds = votingDuration
        }
        if let votes = dict["votes"] as? [String: String] {
            room.votes = votes
        }
        if let votingResultDict = dict["votingResult"] as? [String: Any] {
            room.votingResult = VotingResult.fromDictionary(votingResultDict)
        }
        if let spyGuess = dict["spyGuess"] as? String {
            room.spyGuess = spyGuess
        }
        return room
    }
}

struct VotingResult: Codable {
    let mostVotedPlayer: String
    let spyName: String
    let spyCaught: Bool
    let voteCounts: [String: Int]
    let spyGuessCorrect: Bool?
    
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
        
        return VotingResult(
            mostVotedPlayer: mostVotedPlayer,
            spyName: spyName,
            spyCaught: spyCaught,
            voteCounts: voteCounts,
            spyGuessCorrect: spyGuessCorrect
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
            "name": name
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
        
        var player = Player(name: name, role: role)
        player.playerLocationRole = playerLocationRole
        
        return player
    }
}

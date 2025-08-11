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
    
    private var databaseRef = Database.database().reference()
    private var currentRoomRef: DatabaseReference?
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
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
    
    func createGameRoom(playerCount: Int, playerName: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { 
            completion(false)
            return 
        }
        
        isLoading = true
        errorMessage = ""
        
        let randomLocation = Location.locationData.randomElement() ?? Location(nameKey: "Beach", roles: ["Tourist", "Lifeguard", "Vendor", "Swimmer", "Photographer"])
        let roomCode = generateRoomCode()
        let newRoom = GameRoom(
            id: roomCode,
            hostId: user.uid,
            hostName: playerName,
            location: randomLocation,
            maxPlayers: playerCount,
            players: [Player(name: playerName, role: .player)],
            status: .waiting,
            createdAt: Date()
        )
        
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
                    
                    self.currentRoomRef?.updateChildValues([
                        "players": updatedRoom.players.map { $0.toDictionary() }
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
        
        var updatedRoom = room
        updatedRoom.status = .playing
        updatedRoom.assignRoles()
        
        currentRoomRef?.updateChildValues([
            "status": "playing",
            "players": updatedRoom.players.map { $0.toDictionary() }
        ])
    }
    
    func restartGame() {
        guard let room = currentRoom,
              room.hostId == currentUser?.uid else { return }
        
        var updatedRoom = room
        updatedRoom.status = .waiting
        
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
            "players": updatedRoom.players.map { $0.toDictionary() }
        ])
    }
    
    func leaveRoom() {
        guard let room = currentRoom,
              let user = currentUser else { return }
        
        var updatedPlayers = room.players
        updatedPlayers.removeAll { $0.name == currentPlayerName }
        
        if updatedPlayers.isEmpty {
            currentRoomRef?.removeValue()
        } else {
            currentRoomRef?.updateChildValues([
                "players": updatedPlayers.map { $0.toDictionary() }
            ])
        }
        
        // Clear local state without showing any error message
        currentRoom = nil
        currentPlayerName = ""
        currentRoomRef?.removeAllObservers()
        currentRoomRef = nil
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
    
    enum GameStatus: String, Codable, CaseIterable {
        case waiting = "waiting"
        case playing = "playing"
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
        return [
            "id": id,
            "hostId": hostId,
            "hostName": hostName,
            "location": location.toDictionary(),
            "maxPlayers": maxPlayers,
            "players": players.map { $0.toDictionary() },
            "status": status.rawValue,
            "createdAt": createdAt.timeIntervalSince1970
        ]
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
              let createdAtInterval = dict["createdAt"] as? TimeInterval else {
            return nil
        }
        
        let players = playersArray.compactMap { Player.fromDictionary($0) }
        let createdAt = Date(timeIntervalSince1970: createdAtInterval)
        
        return GameRoom(
            id: id,
            hostId: hostId,
            hostName: hostName,
            location: location,
            maxPlayers: maxPlayers,
            players: players,
            status: status,
            createdAt: createdAt
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

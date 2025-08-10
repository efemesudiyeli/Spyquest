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
    
    func createGameRoom(location: Location, playerCount: Int, playerName: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { 
            completion(false)
            return 
        }
        
        isLoading = true
        errorMessage = ""
        
        let roomCode = generateRoomCode()
        let newRoom = GameRoom(
            id: roomCode,
            hostId: user.uid,
            hostName: playerName,
            location: location,
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
            guard let self = self,
                  let roomData = snapshot.value as? [String: Any],
                  let room = GameRoom.fromDictionary(roomData) else { return }
            
            DispatchQueue.main.async {
                self.currentRoom = room
            }
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
    }
    
    mutating func assignRoles() {
        let spyIndex = Int.random(in: 0..<players.count)
        
        for index in players.indices {
            if index == spyIndex {
                players[index].role = .spy
            } else {
                players[index].role = .player
                players[index].playerLocationRole = location.localizedRoles.randomElement()
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
        return [
            "name": name,
            "role": role?.rawValue ?? "",
            "playerLocationRole": playerLocationRole ?? ""
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Player? {
        guard let name = dict["name"] as? String,
              let roleString = dict["role"] as? String,
              let role = Role(rawValue: roleString) else {
            return nil
        }
        
        let playerLocationRole = dict["playerLocationRole"] as? String
        
        var player = Player(name: name, role: role)
        if let locationRole = playerLocationRole, !locationRole.isEmpty {
            player.playerLocationRole = locationRole
        }
        
        return player
    }
}

//
//  ViewModel.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import Foundation
import SwiftUI
import AudioToolbox

class GameViewModel: ObservableObject {
    @Published var selectedLocation: Location = Location(nameKey: "", roles: [""])
    @Published var players: [Player] = [Player(name: ""),Player(name: ""),Player(name: "")]
    @Published var showingPlayer: Player? = nil
    @Published var timeRemaining: TimeInterval = 8.00 * 60
    @Published var isTimerFinished: Bool = false
    var roundTimer: Timer? = nil
    
    init() {}
    
    init(isSampleData: Bool) {
        self.players = Player.samplePlayers
        selectedLocation = Location(nameKey: "Airplane", roles: ["Host", "Pilot"])
    }
    
    func selectLocation() -> Void {
        if let randomLocation = Location.locationData.randomElement() {
            selectedLocation = randomLocation
        }
    }
    
    private func assignLocationRoles() -> Void {
        for index in players.indices {
            if players[index].role != .spy {
                players[index].playerLocationRole = selectedLocation.localizedRoles.randomElement()
            }
        }
    }
    
    func assignRoles() -> Void {
        let spyIndex = Int.random(in: 0..<players.count)

        for index in players.indices {
            if index == spyIndex {
                players[index].role = .spy
            } else {
                players[index].role = .player
               
            }
        }
    }
    
    func prepareGame() -> Void {
        selectLocation()
        assignRoles()
        assignLocationRoles()
        startRoundTimer()
    }
    
    func increasePlayerSlot() -> Void {
        if players.count < 8 {
            players.append(Player(name: ""))
        }
    }
    
    func decreasePlayerSlot() -> Void {
        if players.count > 3 {
            players.removeLast()
        }
    }
    
    func startRoundTimer() -> Void {
        resetRoundTimer()
        isTimerFinished = false
        roundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.isTimerFinished = true
                self.triggerVibration()
            }
        })
    }
    
    func resetRoundTimer() -> Void {
        roundTimer?.invalidate()
        timeRemaining = 8.00 * 60
    }
    
    func formattedTimeInterval(_ timeInterval: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            
            return formatter.string(from: timeInterval) ?? "00:00"
        }
    
    func triggerVibration() {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
}

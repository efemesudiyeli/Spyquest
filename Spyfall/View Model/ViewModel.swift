//
//  ViewModel.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import Foundation
import SwiftUI
import AudioToolbox
import GoogleMobileAds
import RevenueCat
import StoreKit


class GameViewModel: ObservableObject {
    @Published var selectedLocation: Location = Location(nameKey: "", roles: [""])
    @Published var players: [Player] = [Player(name: ""),Player(name: ""),Player(name: "")]
    @Published var showingPlayer: Player? = nil
    @Published var timeRemaining: TimeInterval = 8.5 * 60
    @Published var isTimerFinished: Bool = false
    
    @Published var isGameStarted: Bool = false
    @Published var isAdsRemoved: Bool = false
    @Published var product: StoreProduct?
    @Published var isPurchasing: Bool = false
    @Published var adCoordinator = AdCoordinator()
    
    @Published var showingRestoreAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isReviewAsked: Bool = false
    
    
    

    var roundTimer: Timer? = nil
    
    init() {
        fetchProduct()
        checkPurchaseStatus()
    }
    
    init(isSampleData: Bool) {
        self.players = Player.samplePlayers
        selectedLocation = Location(nameKey: "Airplane", roles: ["Host", "Pilot"])
    }
    
    // MARK: - Game Functions
    
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
    }
    
    func startNewGame() -> Void {
        if !isGameStarted {
            prepareGame()
            
            if !isAdsRemoved {
                Task {
                    await adCoordinator.loadAd()
                }
                
            }
            startRoundTimer()
            isGameStarted = true
        }
    }
    
    func restartGame() -> Void {
       
        prepareGame()
        
        if !isAdsRemoved {
            Task {
                await adCoordinator.loadAd()
                adCoordinator.presentAd()
            }
            
        }
        startRoundTimer()
        isGameStarted = true
       
    }
    
    func finishGame() -> Void {
      
      
        isGameStarted = false
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
                withAnimation {
                    self.timeRemaining -= 1
                }
               
            } else {
                timer.invalidate()
                self.isTimerFinished = true
                self.triggerVibration()
            }
        })
    }
    
    func resetRoundTimer() -> Void {
        roundTimer?.invalidate()
        timeRemaining = 8.5 * 60
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
    
    // MARK: - Purchases
    
    func fetchProduct() {
        Purchases.shared.getProducts(["iap_noads"]) { (products) in
            if let product = products.first {
                self.product = product
            } else {
                print("Product not found")
            }
        }
    }
    
    func purchaseProduct() {
        guard let product = product else {
            print("Product not available")
            return
        }
        
        isPurchasing = true
        Purchases.shared.purchase(product: product) { (transaction, purchaserInfo, error, userCancelled) in
            self.isPurchasing = false
            
            if let error = error {
                print("Error purchasing: \(error.localizedDescription)")
            } else if userCancelled {
                print("User cancelled purchase.")
            } else if let purchaserInfo = purchaserInfo {
                print("Purchase successful: \(purchaserInfo)")
                self.isAdsRemoved = true
            }
        }
    }
    
    func checkPurchaseStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print("Failed to fetch customer info: \(error.localizedDescription)")
            } else if let customerInfo = customerInfo {
                if customerInfo.entitlements["Pro"]?.isActive == true {
                    self.isAdsRemoved = true
                    print("Customer purchased already.")
                } else {
                    self.isAdsRemoved = false
                    print("Customer not purchased.")
                }
            }
        }
    }
    
    func restorePurchases() {
        Purchases.shared.restorePurchases { (customerInfo, error) in
            if let error = error {
                self.alertMessage = "Restore failed: \(error.localizedDescription)"
                self.showingRestoreAlert = true
            } else if let customerInfo = customerInfo {
                if customerInfo.entitlements["Pro"]?.isActive == true {
                    self.alertMessage = "Purchases restored successfully!"
                    self.isAdsRemoved = true
                } else {
                    self.alertMessage = "No purchases to restore."
                }
                self.showingRestoreAlert = true
            }
        }
    }
    
    // MARK: - Review
    
    func requestReview() {
        if !isReviewAsked {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                isReviewAsked = true
            }
        }
    }
    
   
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
}

class AdCoordinator: NSObject, GADFullScreenContentDelegate {
    private var ad: GADInterstitialAd?
    
    func loadAd() async {
        do {
            ad = try await GADInterstitialAd.load(
                withAdUnitID: "ca-app-pub-7178351830795639/4872282217", request: GADRequest())
            self.ad?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func presentAd() {
        
        guard let fullScreenAd = ad else {
            return print("Ad wasn't ready")
        }
        
        // View controller is an optional parameter. Pass in nil.
        fullScreenAd.present(fromRootViewController: nil)
    }
    
    // MARK: - GADFullScreenContentDelegate methods
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called, \(error.localizedDescription)")
        
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
}






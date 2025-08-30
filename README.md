# 🕵️ Spyquest - Multiplayer Spyfall Game

<div align="center">  
  [![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
  [![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
  [![Firebase](https://img.shields.io/badge/Firebase-Realtime%20Database-yellow.svg)](https://firebase.google.com/)
</div>

## 📖 Overview

**Spyquest** is a modern iOS adaptation of the popular party game **Spyfall**. Built with SwiftUI and Firebase, it offers both local and real-time multiplayer gameplay where players must identify the spy among them while the spy tries to figure out the secret location.

## ✨ Features

### 🎮 Game Modes
- **Local Multiplayer**: Play with friends on the same device (3-8 players)
- **Online Multiplayer**: Real-time gameplay with lobby system (3-8 players)
- **Anonymous Authentication**: Quick join without account creation

### 🌍 Rich Content
- **100+ Locations** across 6 different themed sets:
  - **First Edition**: Classic Spyfall locations (Airplane, Bank, Hospital, etc.)
  - **Second Edition**: Extended locations (Art Museum, Gaming Convention, etc.)
  - **Combined Edition**: Both editions together
  - **Extra Edition**: Custom locations (Aquarium, Brewery, Castle, etc.)
  - **Pirates Edition**: 21 pirate-themed locations with detailed descriptions
  - **Wild West Edition**: 25 western-themed locations with immersive backstories

### 🎯 Core Gameplay
- **Role Assignment**: Automatic spy and location role distribution
- **Timer System**: 8.5-minute rounds with real-time synchronization
- **Voting Mechanism**: Democratic spy identification system
- **Spy Guess Feature**: Strategic location guessing for spies
- **Smart Game Logic**: Complex win/lose conditions handling ties and edge cases

### 🌐 Multiplayer Features
- **Real-time Sync**: Firebase Realtime Database integration
- **Lobby System**: Create/join games with 6-character codes
- **Presence Tracking**: Online/offline player status
- **Host Controls**: Game state management and player coordination
- **Auto-cleanup**: Orphaned lobby detection and removal
- **Graceful Disconnection**: Handles network issues and player drops

### 🎨 User Experience
- **Localization**: Multi-language support (English, Turkish, French)
- **Modern UI**: SwiftUI with iOS 16+ design patterns
- **Responsive Design**: Optimized for various screen sizes
- **Accessibility**: VoiceOver and accessibility features
- **Smooth Animations**: Polished transitions and interactions

### 💎 Premium Features
- **Ad-free Experience**: Remove interstitial advertisements
- **Premium Location Sets**: Access to Pirates and Wild West editions
- **RevenueCat Integration**: Subscription management
- **Restore Purchases**: Cross-device purchase restoration

## 🛠 Technical Architecture

### **Frontend**
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **Combine Framework**: Reactive programming for state management
- **NavigationStack**: iOS 16+ navigation system

### **Backend & Services**
- **Firebase Realtime Database**: Real-time multiplayer synchronization
- **Firebase Anonymous Auth**: Seamless user authentication
- **RevenueCat**: Subscription and in-app purchase management
- **Google Mobile Ads**: Monetization through interstitial ads

### **Key Components**
```
├── Models/
│   ├── Location.swift          # Game locations and themes
│   └── Player.swift           # Player data and roles
├── ViewModels/
│   ├── GameViewModel.swift     # Local game logic
│   └── MultiplayerGameViewModel.swift  # Online multiplayer logic
├── Views/
│   ├── MainMenuView.swift      # App entry point
│   ├── MultiplayerLobbyView.swift  # Online lobby management
│   ├── GamePlayingView.swift   # Active gameplay interface
│   ├── VotingView.swift        # Voting mechanism
│   └── RoleRevealView.swift    # Role assignment display
└── Extensions/
    ├── Bundle.swift           # App configuration
    └── View.swift            # UI extensions
```

## 🎯 Game Rules

### **Objective**
- **Players**: Identify the spy before time runs out
- **Spy**: Figure out the location without getting caught

### **Gameplay Flow**
1. **Setup**: App assigns roles and secret location
2. **Discussion**: Players ask questions about the location
3. **Voting**: Democratic process to identify the spy
4. **Spy Guess**: Spy can guess the location at any time
5. **Resolution**: Win conditions based on voting results and spy actions

### **Win Conditions**
- **Players Win**: Spy is correctly identified OR spy guesses wrong location
- **Spy Wins**: Spy correctly guesses location OR voting results in tie/wrong accusation

## 🚀 Technical Highlights

### **Real-time Multiplayer**
- Server-synchronized timers with offset compensation
- Presence tracking with automatic cleanup
- Robust error handling for network issues
- Optimistic UI updates for smooth experience

### **Smart Game Logic**
- Complex voting resolution with tie-breaking rules
- Majority vote detection with time reduction
- Auto-game ending when conditions are met
- State persistence across network disruptions

### **Performance Optimizations**
- Efficient Firebase queries with minimal data transfer
- Memory management with weak references
- Background processing for non-critical operations
- Optimized UI updates on main thread

### **Security & Privacy**
- Anonymous authentication for privacy
- Secure lobby codes with collision prevention
- Input validation and sanitization
- No personal data collection

## 📱 System Requirements

- **iOS**: 17.0+
- **Xcode**: 14.0+
- **Swift**: 5.7+
- **Device**: iPhone

## 🎨 Design Philosophy

The app follows Apple's Human Interface Guidelines with:
- **Intuitive Navigation**: Clear user flows and logical information architecture
- **Consistent Visual Language**: Unified color scheme and typography
- **Accessibility First**: VoiceOver support and inclusive design
- **Performance**: Smooth 60fps animations and responsive interactions

## 🔧 Development Features

### **Code Quality**
- **MVVM Architecture**: Clean separation of business logic and UI
- **Memory Safety**: No force unwraps, proper optional handling
- **Error Handling**: Comprehensive error states and user feedback
- **Localization**: Internationalization support with string catalogs

### **Testing & Debugging**
- **Preview Support**: SwiftUI previews for rapid development
- **Debug Logging**: Conditional compilation for production builds
- **Crash Prevention**: Defensive programming practices

## 🌟 Portfolio Highlights

This project demonstrates expertise in:

- **iOS Development**: Advanced SwiftUI, Combine, and iOS SDK usage
- **Real-time Systems**: Firebase integration with complex state management
- **User Experience**: Polished UI/UX with accessibility considerations
- **Architecture**: Scalable MVVM pattern with clean code practices
- **Monetization**: Premium features and ad integration
- **Localization**: Multi-language support and cultural adaptation
- **Game Development**: Complex game logic and state machines
- **Performance**: Optimized for smooth real-time multiplayer experience

---

**Spyquest** represents a complete iOS application showcasing modern development practices, real-time multiplayer capabilities, and polished user experience design. The project demonstrates proficiency in advanced iOS development concepts while delivering an engaging and accessible gaming experience.

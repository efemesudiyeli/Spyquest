import SwiftUI
import FirebaseAuth

struct MultiplayerLobbyView: View {
    @StateObject private var viewModel = MultiplayerGameViewModel()
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingCreateRoom = false
    @State private var showingJoinRoom = false
    @State private var roomCode = ""
    @State private var playerCount = 2
    @State private var playerName = ""
    @State private var navigateToGame = false
    @State private var selectedLocationSet: LocationSets = .spyfallOne
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !viewModel.isAuthenticated && false {
                    // Show loading while auto-signing in
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("Signing you in...")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                } else {
                    lobbyView
                }
            }
            .padding()
            .navigationTitle("Online Mode")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Auto-sign in anonymously if not already authenticated
                if !viewModel.isAuthenticated && !viewModel.isLoading {
                    viewModel.signInAnonymously()
                }
            }
        }
        .sheet(isPresented: $showingCreateRoom) {
            createRoomSheet
        }
        .background(
            NavigationLink(destination: MultiplayerGameView(viewModel: viewModel), isActive: $navigateToGame) {
                EmptyView()
            }
        )
        .alert("Join Your Friends", isPresented: $showingJoinRoom) {
            TextField("Your Name", text: $playerName)
                .textInputAutocapitalization(.words)
            TextField("Room Code", text: $roomCode)
                .textInputAutocapitalization(.characters)
            Button("Join") {
                if !roomCode.isEmpty && !playerName.isEmpty {
                    viewModel.joinRoom(roomCode: roomCode.uppercased(), playerName: playerName) { success in
                        if success {
                            navigateToGame = true
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your name and the 6-digit room code")
        }
        .alert("Room Update", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var lobbyView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                        Spacer()
                    }
                    Text("Welcome!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    Text("Ready to play with friends?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontDesign(.monospaced)
                }
                Spacer()
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    showingCreateRoom = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.reverse2)
                            .font(.title2)
                        VStack(alignment: .leading){
                            Text("Create New Room")
                                .fontWeight(.semibold)
                            Text("Start a new game and get a room code.")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }.multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    showingJoinRoom = true
                }) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.right.circle.fill")
                            .foregroundColor(.reverse2)
                            .font(.title2)
                        VStack(alignment: .leading){
                            Text("Join Existing Room")
                                .fontWeight(.semibold)
                            Text("Enter a code to join your friend’s game.")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }.multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            

            
            Spacer()
            
            VStack {
                Text("Tip:")
                    .bold()
                Text("Share the room code with friends to start playing!")
            }   .font(.callout)
                .fontDesign(.monospaced)
        }
    }
    
    private var createRoomSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Name")
                        .font(.headline)
                    
                    TextField("Enter your name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Number of Players")
                        .font(.headline)
                    
                    Stepper("\(playerCount) players", value: $playerCount, in: 2...8)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Location Set")
                        .font(.headline)
                    
                    Picker("Location Set", selection: $selectedLocationSet) {
                        ForEach(LocationSets.locationSets, id: \.self) { locationSet in
                            Text("\(locationSet.rawValue) (\(locationSet.locations.count))")
                                .tag(locationSet)
                        }
                        ForEach(LocationSets.premiumSets, id: \.self) { premiumSet in
                            if gameViewModel.isAdsRemoved {
                                Text("\(premiumSet.rawValue) (\(premiumSet.locations.count))")
                                    .tag(premiumSet)
                            } else {
                                HStack {
                                    Text("\(premiumSet.rawValue) (\(premiumSet.locations.count))")
                                        .foregroundStyle(.gray)
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                }
                                .tag(premiumSet)
                                .selectionDisabled()
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    if !playerName.isEmpty {
                        viewModel.createGameRoom(playerCount: playerCount, playerName: playerName, selectedLocationSet: selectedLocationSet) { success in
                            if success {
                                showingCreateRoom = false
                                navigateToGame = true
                            }
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text("Create Room")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading || playerName.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingCreateRoom = false
                    }
                }
            }
        }
    }
}



#Preview {
    MultiplayerLobbyView(gameViewModel: GameViewModel())
}

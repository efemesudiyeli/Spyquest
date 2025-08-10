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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !viewModel.isAuthenticated {
                    authenticationView
                } else {
                    lobbyView
                }
            }
            .padding()
            .navigationTitle("Multiplayer")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCreateRoom) {
            createRoomSheet
        }
        .background(
            NavigationLink(destination: MultiplayerGameView(viewModel: viewModel), isActive: $navigateToGame) {
                EmptyView()
            }
        )
        .alert("Join Room", isPresented: $showingJoinRoom) {
            TextField("Your Name", text: $playerName)
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
    
    private var authenticationView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Sign in to play multiplayer")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.signInAnonymously()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "person.fill")
                    }
                    Text("Sign In Anonymously")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private var lobbyView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Ready to play with friends?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    showingCreateRoom = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("Create New Room")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    showingJoinRoom = true
                }) {
                    HStack {
                        Image(systemName: "person.2.circle.fill")
                            .foregroundColor(.blue)
                        Text("Join Existing Room")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            

            
            Spacer()
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
                
                Button(action: {
                    if !playerName.isEmpty {
                        viewModel.createGameRoom(playerCount: playerCount, playerName: playerName) { success in
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

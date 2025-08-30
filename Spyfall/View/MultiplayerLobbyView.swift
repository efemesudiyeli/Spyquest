import SwiftUI
import FirebaseAuth

struct MultiplayerLobbyView: View {
    @StateObject private var viewModel = MultiplayerGameViewModel()
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingCreateLobby = false
    @State private var showingJoinLobby = false
    @State private var lobbyCode = ""
    @State private var playerCount = 3
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
                // Sync premium status with GameViewModel
                viewModel.setGameViewModel(gameViewModel)
            }
        }
        .sheet(isPresented: $showingCreateLobby) {
            createLobbySheet
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingJoinLobby) {
            joinLobbySheet
                .presentationDetents([.medium])
        }
        .navigationDestination(isPresented: $navigateToGame) {
            MultiplayerGameView(viewModel: viewModel)
        }
        .alert("Lobby Update", isPresented: .constant(!viewModel.errorMessage.isEmpty && !showingJoinLobby)) {
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
                    showingCreateLobby = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.reverse2)
                            .font(.title2)
                        VStack(alignment: .leading){
                            Text("Create New Lobby")
                                .fontWeight(.semibold)
                            Text("Start a new game and get a lobby code.")
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
                    showingJoinLobby = true
                }) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.right.circle.fill")
                            .foregroundColor(.reverse2)
                            .font(.title2)
                        VStack(alignment: .leading){
                            Text("Join Existing Lobby")
                                .fontWeight(.semibold)
                            Text("Enter a code to join your friend’s game")
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
                Text("Share the lobby code with friends to start playing!")
            }   .font(.callout)
                .fontDesign(.monospaced)
        }
    }
    
    fileprivate var createLobbySheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "person.3.fill")
                                    .font(.headline)
                                    .foregroundColor(.reverse2)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lobby Details")
                                    .font(.headline)
                                Text("Set your name, players, and locations")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)

                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: "person.fill").foregroundColor(.secondary)
                            TextField("Enter your name", text: $playerName)
                                .textInputAutocapitalization(.words)
                                .textContentType(.name)
                                .submitLabel(.done)
                                .onSubmit {
                                    if !playerName.isEmpty {
                                        viewModel.createGameLobby(
                                            playerCount: playerCount,
                                            playerName: playerName,
                                            selectedLocationSet: selectedLocationSet
                                        ) { success in
                                            if success {
                                                showingCreateLobby = false
                                                navigateToGame = true
                                            }
                                        }
                                    }
                                }
                        }
                        .padding(.vertical, 12)

                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill").foregroundColor(.secondary)
                            Text("Players")
                            Spacer()
                            Text("\(playerCount)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Stepper("", value: $playerCount, in: 3...8)
                                .labelsHidden()
                        }
                        .padding(.vertical, 12)

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "map.fill").foregroundColor(.secondary)
                                Text("Location Set")
                                Spacer()
                                Picker("", selection: $selectedLocationSet) {
                                    ForEach(LocationSets.locationSets, id: \.self) { locationSet in
                                        Text("\(locationSet.rawValue) (\(locationSet.locations.count))")
                                            .tag(locationSet)
                                    }
                                    ForEach(LocationSets.premiumSets, id: \.self) { premiumSet in
                                        if gameViewModel.isPremium {
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
                                .labelsHidden()
                                .pickerStyle(.menu)
                            }

                            if !gameViewModel.isPremium {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill").foregroundColor(.yellow)
                                    Text("Premium sets require the Premium upgrade.")
                                        .foregroundColor(.secondary)
                                }
                                .font(.caption)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button(action: {
                        if !playerName.isEmpty {
                            viewModel.createGameLobby(
                                playerCount: playerCount,
                                playerName: playerName,
                                selectedLocationSet: selectedLocationSet
                            ) { success in
                                if success {
                                    showingCreateLobby = false
                                    navigateToGame = true
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text("Create Lobby")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.reverse2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || playerName.isEmpty)
                    .opacity((viewModel.isLoading || playerName.isEmpty) ? 0.7 : 1)

                    if playerName.isEmpty {
                        Text("Enter your name to continue.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create Lobby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingCreateLobby = false
                    }
                }
            }
        }
    }

    fileprivate var joinLobbySheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if !viewModel.errorMessage.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            Button(action: { viewModel.errorMessage = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.reverse2)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Join Lobby")
                                    .font(.headline)
                                Text("Enter your name and lobby code")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)

                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: "person.fill").foregroundColor(.secondary)
                            TextField("Enter your name", text: $playerName)
                                .textInputAutocapitalization(.words)
                                .textContentType(.name)
                                .submitLabel(.next)
                        }
                        .padding(.vertical, 12)

                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: "number").foregroundColor(.secondary)
                            TextField("Lobby code", text: $lobbyCode)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .textCase(.uppercase)
                                .submitLabel(.join)
                                .onSubmit {
                                    if !lobbyCode.isEmpty && !playerName.isEmpty {
                                        viewModel.joinLobby(
                                            lobbyCode: lobbyCode.uppercased(),
                                            playerName: playerName
                                        ) { success in
                                            if success {
                                                showingJoinLobby = false
                                                navigateToGame = true
                                            }
                                        }
                                    }
                                }
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button(action: {
                        if !lobbyCode.isEmpty && !playerName.isEmpty {
                            viewModel.joinLobby(
                                lobbyCode: lobbyCode.uppercased(),
                                playerName: playerName
                            ) { success in
                                if success {
                                    showingJoinLobby = false
                                    navigateToGame = true
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "arrow.right")
                            }
                            Text("Join Lobby")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.reverse)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.reverse2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || lobbyCode.isEmpty || playerName.isEmpty)
                    .opacity((viewModel.isLoading || lobbyCode.isEmpty || playerName.isEmpty) ? 0.7 : 1)

                    if lobbyCode.isEmpty || playerName.isEmpty {
                        Text("Enter your name and lobby code to continue.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Join Lobby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingJoinLobby = false
                    }
                }
            }
            .onAppear {
                viewModel.errorMessage = ""
            }
        }
    }
}



#Preview {
    MultiplayerLobbyView(gameViewModel: GameViewModel())
}

#Preview("Create Lobby Sheet") {
    let gameViewModel = GameViewModel()
    let lobbyView = MultiplayerLobbyView(gameViewModel: gameViewModel)
    return lobbyView.createLobbySheet
}

#Preview("Join Lobby Sheet") {
    let gameViewModel = GameViewModel()
    let lobbyView = MultiplayerLobbyView(gameViewModel: gameViewModel)
    return lobbyView.joinLobbySheet
}

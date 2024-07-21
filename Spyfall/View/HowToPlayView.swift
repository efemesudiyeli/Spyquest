//
//  HowToPlayView.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 19.07.2024.
//

import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        List {
            Section {
                Text("The app automatically assigns roles and locations to each player.")
            } header: {
                Text("1. Setup")
            }
            
            Section {
                Text("""
**Players:** Identify the spy before time runs out.
**Spy:** Figure out the location without getting caught.
""")
            } header: {
                Text("2. Objective")
            }
            
            Section {
                Text("""
**Ask Questions:** Take turns asking questions about the location. Players answer honestly, while the spy tries to blend in.
**Give Answers:** Provide answers related to the location. Be cautious not to reveal too much to the spy.
""")
            } header: {
                Text("3. Gameplay")
            }
            
            Section {
                Text("""
At any time, players can discuss and vote to accuse someone of being the spy.
If the accused is the spy, the players win. If not, spy wins.
""")
            } header: {
                Text("4. Guess the Spy")
            }
            
            Section {
                Text("""
The spy can guess the location at any time. 
If correct, the spy wins.
If wrong, the players win.
""")
            } header: {
                Text("5. Spy's Turn")
            }
            
            Section {
                Text("""
The game ends when the spy is correctly identified or the spy guesses the location correctly.
""")
            } header: {
                Text("6. End of Game")
            }
            
            Section {
                Text("""
**For Players:** Be strategic with your questions and answers.
**For the Spy:** Listen carefully to the answers and use your guesses wisely.
""")
            } header: {
                Text("7. Tips")
            }
        }.navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
}

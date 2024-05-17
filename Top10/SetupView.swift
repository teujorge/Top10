//
//  SetupView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import SwiftUI

struct SetupView: View {
    
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    
    @State private var players: [String] = [] // State variable to hold the list of players
    @State private var playerName = "" // State variable to hold the current player name
    
    @FocusState private var isTextFieldFocused: Bool
    
    
    private func addPlayer() {
        if !playerName.isEmpty {
            players.append(playerName)
            playerName = ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Players: \(players.count)")) {
                    ForEach(players, id: \.self) { player in
                        Text(player)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    if let index = players.firstIndex(of: player) {
                                        players.remove(at: index)
                                    }
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    TextField("Enter player name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                    
                    Button(action: addPlayer) {
                        Image(systemName: "plus")
                    }
                    .padding(4)
                }
                .padding()
                
                NavigationLink(destination: GameView(category: category, top10: top10, players: players)) {
                    Text(players.isEmpty ? "Start Solo Game" : "Start Game")
                }
                    .padding()
            }

        }
        .navigationTitle("Game Setup")
        .onAppear() {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    SetupView(category: "Fruits", top10: ["Apple", "Banana", "Cherry"])
}

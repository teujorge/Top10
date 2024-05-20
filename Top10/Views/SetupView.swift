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
    
    private func addPlayer() {
        if !playerName.isEmpty {
            players.append(playerName)
            playerName = ""
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
        
            
            VStack {
                NavigationLink(destination: GameView(category: category, top10: top10, players: players)) {
                    Text(players.isEmpty ? "Start Solo Game" : "Start Game")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                .cornerRadius(12)
                
                HStack {
                    TextField("Enter player name", text: $playerName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: addPlayer) {
                        Image(systemName: "plus")
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(.circle)
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)

        }
        .navigationTitle("Game Setup")
    }
}

// MARK: - Preview

#Preview {
    SetupView(category: "Fruits", top10: ["Apple", "Banana", "Cherry"])
}

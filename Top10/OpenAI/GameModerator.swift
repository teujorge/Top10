//
//  GameModerator.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI
import OpenAI

let openAI = OpenAI(apiToken: "sk-proj-FeJPsDDeKdtbaNvuhwVTT3BlbkFJGc4eSNc1wa2lz2bVvrUb")

struct GuessResponse {
    let match: String?
    let suggestion: String?
}

/**
 Analyzes the user's guess against the correct answers and provides a response.

 This function leverages AI to evaluate the user's guess in comparison to a list of correct answers. It allows for minor variations and similar concepts, making it more forgiving of close matches and slight misspellings (e.g., "mercedes", "mercedes-benz", "benz").

 - Parameters:
   - answers: An array of correct answers to the question.
   - guess: The user's guess as a String.
 - Returns: A `GuessResponse` object containing the response, an indicator of whether the guess is correct, and a suggestion if the guess is incorrect or not understandable.
 */
func handleUserGuess(answers: [String], guess: String, entitlementManager: EntitlementManager) async -> GuessResponse? {
    // Create the prompt for the AI
    let prompt = """
    The user's guess is: \(guess)
    Here are the correct answers: \(answers.joined(separator: ", "))
    
    First, determine if the guess is understandable.
    If not understandable, respond with only the text "suggestion: XYZ" where XYZ is the suggested correct form.
    If understandable, continue.
    
    Second, determine if the guess is correct or close enough to the correct answers.
    If correct, respond with only the text "match: XYZ" where XYZ is the correct answer.
    If not correct enough, respond with only the text "<$>incorrect<$>".
    """

    let query = ChatQuery(
        messages: [ .init(role: .system, content: prompt)! ],
        model: .gpt3_5Turbo
    )

    do {
        let result = try await openAI.chats(query: query)

        let cost = calculateGPT35Cost(promptTokens: result.usage?.promptTokens, completionTokens: result.usage?.completionTokens)
        entitlementManager.addCost(cost)
        
        if let textResult = result.choices.first?.message.content?.string {
            // Parse the AI response
            var match: String?
            var suggestion: String?
            
            if textResult.lowercased().contains("match:") {
                match = textResult.replacingOccurrences(of: "match:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if textResult.lowercased().contains("<$>incorrect<$>") {
                match = nil
            } 
            
            if textResult.lowercased().contains("suggestion:") {
                match = nil
                suggestion = textResult.replacingOccurrences(of: "suggestion:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }

            print("Guess: \(guess)")
            print("Response: \(textResult)")
            print("Match: \(match ?? "nil")")
            print("Suggestion: \(suggestion ?? "nil")")

            return GuessResponse(match: match, suggestion: suggestion)
        }
    } catch {
        print("Error: \(error)")
    }

    return nil
}



/**
 Generates a list of the top ten items for a given category.

 This function retrieves the top ten items for a given category from the OpenAI API.

 - Parameters:
   - category: The category for which to generate the top ten list.
 - Returns: An array of the top ten items for the specified category.
 */
func generateTopTen(category: String, entitlementManager: EntitlementManager) async -> [String]? {
    // Create the prompt for the AI
    let prompt = """
    Generate the top ten items for the category: \(category)
    
    Respond only with a comma-separated list of the top ten items.
    E.g., "Car, Boat, ..., Truck
    """
    
    let query = ChatQuery(
        messages: [ .init(role: .system, content: prompt)! ],
        model: .gpt3_5Turbo
    )
    
    do {
        let result = try await openAI.chats(query: query)

        let cost = calculateGPT35Cost(promptTokens: result.usage?.promptTokens, completionTokens: result.usage?.completionTokens)
        entitlementManager.addCost(cost)
        
        if let textResult = result.choices.first?.message.content?.string {
            let top10 = textResult.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            print("Category: \(category)")
            print("Response: \(textResult)")
            print("Top 10: \(top10)")
            
            return top10
        }
    } catch {
        print("Error: \(error)")
    }
    
    return nil
}


func calculateGPT35Cost(promptTokens: Int?, completionTokens: Int?) -> Double {
    
    // gpt-3.5-turbo-0125
    // INPUT : $0.50 / 1M tokens
    // OUTPUT : $1.50 / 1M tokens
    
    let promptTokenCostPerToken = 0.50 / 1_000_000
    let completionTokenCostPerToken = 1.50 / 1_000_000
    
    let cost = (Double(promptTokens ?? 0) * promptTokenCostPerToken) + (Double(completionTokens ?? 0) * completionTokenCostPerToken)
    
    print("Cost: \(cost)")
    print("Prompt Tokens: \(promptTokens ?? 0)")
    print("Completion Tokens: \(completionTokens ?? 0)")
    
    return cost
}

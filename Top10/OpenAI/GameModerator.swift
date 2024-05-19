//
//  GameModerator.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import OpenAI
import AVFoundation

/**
 Analyzes the user's guess against the correct answers and provides a response.
 
 This function leverages AI to evaluate the user's guess in comparison to a list of correct answers. It allows for minor variations and similar concepts, making it more forgiving of close matches and slight misspellings (e.g., "mercedes", "mercedes-benz", "benz").
 
 - Parameters:
 - answers: An array of correct answers to the question.
 - guess: The user's guess as a String.
 - Returns: A `GuessResponse` object containing the response, an indicator of whether the guess is correct, and a suggestion if the guess is incorrect or not understandable.
 */
func handleUserGuess(
    answers: [String],
    guess: String,
    conversationHistory: [ChatQuery.ChatCompletionMessageParam],
    entitlementManager: EntitlementManager
) async -> GuessResponse? {
    // Create the prompt for the AI
    let initialPrompt = """
    Here are the correct answers: \(answers.joined(separator: ", "))
    
    Always respond with JSON in the following format:
    {
        "match": String or null,
        "suggestion": String or null,
        "speech": String
    }
    
    First, determine if the guess is understandable.
    If not understandable, respond with JSON in the format:
    {
        "match": null,
        "suggestion": "[A correct word or phrase suggestion here]",
        "speech": "[Your contextual response here]"
    }
    
    If understandable, continue to determine if the guess is close enough to the correct answers. A guess is considered close if it is within a reasonable range of similarity and context to the correct answers. For example;
    "mercedes" and "Mercedes-Benz" is considered close.
    "the rock" and "Dwayne Johnson" is considered close.
    "the guy from Die Hard" and "Bruce Willis" is not considered close.
    
    
    If correct, respond with JSON in the format:
    {
        "match": "[The correct answer here]",
        "suggestion": null,
        "speech": null
    }
    
    If not correct enough, respond with JSON in the format:
    {
        "match": null,
        "suggestion": null,
        "speech": "[Your contextual response here]"
    }
    
    IMPORTANT: Please remember that suggestions and speeches are not suppose to reveal the correct answers! They are meant to guide the user (feel free to give specific clues) to the correct answer without giving it away.
    """
    
    var conversation = conversationHistory +
    [ conversationHistory.isEmpty
      ? .init(role: .user, content: initialPrompt)!
      : .init(role: .user, content: guess)!
    ]
    let model = Model.gpt4_o
    let query = ChatQuery(
        messages: conversation,
        model: model
    )
    
    do {
        let result = try await openAI.chats(query: query)
        
        let cost = calculateGPTCost(model: model, promptTokens: result.usage?.promptTokens, completionTokens: result.usage?.completionTokens)
        entitlementManager.incurCost(cost)
        
        if let textResult = result.choices.first?.message.content?.string {
            // Print raw results for debugging
            print("Raw AI Response:")
            print(textResult)
            
            // Parse the AI response
            guard let jsonData = textResult.data(using: .utf8) else {
                print("Error: Unable to convert response to data")
                return nil
            }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(GuessResponse.self, from: jsonData)
            
            print("Guess: \(guess)")
            print("Response: \(textResult)")
            print("Match: \(response.match ?? "nil")")
            print("Suggestion: \(response.suggestion ?? "nil")")
            print("Speech: \(response.speech ?? "nil")")
            
            // Add response to conversation
            conversation.append( .init(role: .system, content: textResult)! )
            return GuessResponse(match: response.match, suggestion: response.suggestion, speech: response.speech, conversation: conversation)
        }
    } catch {
        print("Error: \(error)")
    }
    
    return nil
}

struct GuessResponse: Decodable {
    let match: String?
    let suggestion: String?
    let speech: String?
    let conversation: [ChatQuery.ChatCompletionMessageParam]?
}

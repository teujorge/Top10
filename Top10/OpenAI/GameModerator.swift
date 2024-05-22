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
    conversationHistory: [ChatQuery.ChatCompletionMessageParam]
) async -> GuessResponse? {
    // Create the prompt for the AI
    let initialPrompt = """
    You are the game host and moderator. Evaluate the user's guess against the correct answers and respond accordingly. You can be sarcastic, funny, sincere, or helpful but always respectful.

    Here are the correct answers: \(answers.joined(separator: ", "))

    Always respond with JSON in the following format:
    {
        "match": String or null,
        "speech": String or null,
        "isHint": Bool,
        "hasGuessed": Bool
    }

    Criteria for a correct guess:
    - Exact matches or close variations (e.g., "mercedes" and "Mercedes-Benz" are considered close).
    
    If the guess has already been made, respond with:
    {
        "match": null,
        "speech": "[Your contextual response here]",
        "isHint": false,
        "hasGuessed": true
    }
    
    If the user asks for a hint, provide a helpful hint without revealing the answer, and respond with:
    {
        "match": null,
        "speech": "[Your hint here]",
        "isHint": true,
        "hasGuessed": false
    }

    If the guess is correct, respond with:
    {
        "match": "[The correct answer here]",
        "speech": null,
        "isHint": false,
        "hasGuessed": false
    }

    If the guess is incorrect, respond with:
    {
        "match": null,
        "speech": "[Your contextual response here]",
        "isHint": false,
        "hasGuessed": false
    }

    IMPORTANT: Do not reveal the correct answers in the "speech". Keep responses direct and concise (max 200 characters).
    """

    
    // Append the user's guess to the conversation history
    var conversation = conversationHistory
    if conversationHistory.isEmpty {
        conversation.append( .init(role: .system, content: initialPrompt)! )
    }
    conversation.append( .init(role: .user, content: guess)! )
    
    let model = Model.gpt3_5Turbo
    let query = ChatQuery(
        messages: conversation,
        model: model,
        responseFormat: .jsonObject
    )
    
    do {
        let result = try await openAI.chats(query: query)
        
//        let cost = calculateGPTCost(model: model, promptTokens: result.usage?.promptTokens, completionTokens: result.usage?.completionTokens)
        
        if let textResult = result.choices.first?.message.content?.string {
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
            print("Speech: \(response.speech ?? "nil")")
            print("Is Hint: \(response.isHint)")
            print("Has Guessed: \(response.hasGuessed)")
            
            // Add response to conversation
            conversation.append( .init(role: .system, content: textResult)! )
            return GuessResponse(
                match: response.match,
                speech: response.speech,
                isHint: response.isHint,
                hasGuessed: response.hasGuessed,
                conversation: conversation
            )
        }
    } catch {
        print("Error: \(error)")
    }
    
    return nil
}

struct GuessResponse: Decodable {
    let match: String?
    let speech: String?
    let isHint: Bool
    let hasGuessed: Bool
    let conversation: [ChatQuery.ChatCompletionMessageParam]?
}

//
//  UtilsOpenAI.swift
//  Top10
//
//  Created by Matheus Jorge on 5/19/24.
//

import OpenAI
import AVFAudio
import Foundation

/// The OpenAI API client
let openAI = OpenAI(apiToken: "ABCD")

/**
 Calculates the cost of using the GPT model for a given number of prompt and completion tokens.

 This function calculates the cost of using the GPT model for a given number of prompt and completion tokens.

 - Parameters:
   - promptTokens: The number of tokens used for the prompt.
   - completionTokens: The number of tokens used for the completion.
 - Returns: The total cost of using the GPT model for the given number of tokens.
 */
func calculateGPTCost(model: Model, promptTokens: Int?, completionTokens: Int?) -> Double {
    
    // gpt-3.5-turbo-0125
    // INPUT : $0.50 / 1M tokens
    // OUTPUT : $1.50 / 1M tokens
    
    // gpt-4o
    // INPUT : $5.00 / 1M tokens
    // OUTPUT : $15.00 /  1M tokens
    
    let promptTokenCostPerToken = (model == .gpt3_5Turbo ? 0.50 : 5.00) / 1_000_000
    let completionTokenCostPerToken = (model == .gpt3_5Turbo ? 1.50 : 15.00) / 1_000_000
    
    // TODO: remove the *30 multiplier once the token count is accurate
    let cost = (Double(promptTokens ?? 0) * promptTokenCostPerToken) + (Double(completionTokens ?? 0) * completionTokenCostPerToken) * 30
    
    print("GPT3.5 Cost: \(cost)")
    print("Prompt Tokens: \(promptTokens ?? 0)")
    print("Completion Tokens: \(completionTokens ?? 0)")
    
    return cost*30
}

/**
 Calculates the cost of using the TTS model for a given number of characters.

 This function calculates the cost of using the TTS model for a given number of characters.

 - Parameters:
   - characters: The number of characters used for the TTS.
   - isHD: A boolean indicating whether the TTS is in HD quality.
 - Returns: The total cost of using the TTS model for the given number of characters.
 */
func calculateTTSCost(characters: Int, isHD: Bool) -> Double {
    
    // TTS
    // $15.00 / 1M characters
    // TTS HD
    // $30.00 / 1M characters
    
    let costPerCharacter = isHD ? 30.00 / 1_000_000 : 15.00 / 1_000_000
    
    // TODO: remove the *30 multiplier once the token count is accurate
    let cost = Double(characters) * costPerCharacter * 30
    
    print("TTS Cost: \(cost)")
    print("Characters: \(characters)")
    
    return cost
}

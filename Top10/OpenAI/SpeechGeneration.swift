//
//  SpeechGeneration.swift
//  Top10
//
//  Created by Matheus Jorge on 5/19/24.
//

import OpenAI
import Foundation

/**
 Generates speech from the specified input text.

 This function generates speech from the specified input text using the OpenAI API.

 - Parameters:
   - input: The input text to be converted into speech.
 - Returns: The audio data containing the speech generated from the input text.
 */
func generateSpeech(input: String) async -> Data? {
    let model = Model.tts_1
    let query = AudioSpeechQuery(model: model, input: input, voice: .nova, speed: 1.0)
    
    do {
        let result = try await openAI.audioCreateSpeech(query: query)
        
//        let cost = calculateTTSCost(characters: input.count, isHD: model == .tts_1_hd)
        
        return result.audio
    }
    catch {
        print("Error: \(error)")
        return nil
    }
}

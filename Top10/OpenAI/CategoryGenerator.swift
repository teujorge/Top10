//
//  CategoryGenerator.swift
//  Top10
//
//  Created by Matheus Jorge on 5/19/24.
//

import OpenAI

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
        entitlementManager.incurCost(cost)
        
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

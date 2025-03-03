//
//  OnboardingViewModel.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftUI

@Observable
class OnboardingViewModel {
    var apiKey: String = ""
    var isValidating: Bool = false
    var errorMessage: String?
    var isAPIKeyValid: Bool = false
    
    func validateAPIKey() async {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "API key cannot be empty"
            isAPIKeyValid = false
            return
        }
        
        isValidating = true
        errorMessage = nil
        
        do {
            // Validate API key with API client
            isAPIKeyValid = try await APIClient.shared.validateAPIKey(apiKey)
            
            if isAPIKeyValid {
                // Save API key to Keychain
                try KeychainManager.shared.saveAPIKey(apiKey)
                errorMessage = nil
            } else {
                errorMessage = "Invalid API key"
            }
        } catch {
            isAPIKeyValid = false
            errorMessage = error.localizedDescription
        }
        
        isValidating = false
    }
    
    func checkForExistingAPIKey() {
        do {
            apiKey = try KeychainManager.shared.getAPIKey()
            isAPIKeyValid = !apiKey.isEmpty
        } catch {
            // No API key found or error retrieving it
            apiKey = ""
            isAPIKeyValid = false
        }
    }
}

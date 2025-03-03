//
//  ChatViewModel.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ChatViewModel {
    private let modelContext: ModelContext
    var chat: Chat
    var messageText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext, chat: Chat? = nil) {
        self.modelContext = modelContext
        
        if let existingChat = chat {
            self.chat = existingChat
        } else {
            self.chat = Chat()
            modelContext.insert(self.chat)
        }
    }
    
    var messages: [ChatMessage] {
        return chat.messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(sender: .user, text: messageText, chat: chat)
        messageText = ""
        
        modelContext.insert(userMessage)
        chat.updatedAt = Date()
        
        do {
            try modelContext.save()
            
            isLoading = true
            errorMessage = nil
            
            // Get API key from Keychain
            let apiKey: String?
            do {
                apiKey = try KeychainManager.shared.getAPIKey()
            } catch {
                apiKey = nil
            }
            
            // Send message to API
            let response = try await APIClient.shared.sendMessage(userMessage.text, apiKey: apiKey)
            
            // Create assistant message with response
            let assistantMessage = ChatMessage(sender: .assistant, text: response, chat: chat)
            modelContext.insert(assistantMessage)
            chat.updatedAt = Date()
            
            try modelContext.save()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteMessage(_ message: ChatMessage) {
        modelContext.delete(message)
        chat.updatedAt = Date()
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

//
//  ChatMessage.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData

enum Sender: String, Codable {
    case user
    case assistant
}

@Model
final class ChatMessage {
    var id: UUID
    var sender: String // Using String to store Sender enum value for SwiftData compatibility
    var text: String
    var timestamp: Date
    
    var chat: Chat?
    
    var senderType: Sender {
        return Sender(rawValue: sender) ?? .assistant
    }
    
    init(id: UUID = UUID(), sender: Sender, text: String, timestamp: Date = Date(), chat: Chat? = nil) {
        self.id = id
        self.sender = sender.rawValue
        self.text = text
        self.timestamp = timestamp
        self.chat = chat
    }
}

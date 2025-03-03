//
//  Chat.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData

@Model
final class Chat {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade)
    var messages: [ChatMessage] = []
    
    init(id: UUID = UUID(), title: String = "New Chat", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

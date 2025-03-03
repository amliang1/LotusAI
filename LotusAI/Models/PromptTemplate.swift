//
//  PromptTemplate.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData

@Model
final class PromptTemplate {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isDefault: Bool
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date(), isDefault: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
    }
}

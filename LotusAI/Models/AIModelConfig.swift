//
//  AIModelConfig.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData

enum AIProvider: String, Codable, CaseIterable {
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case custom = "Custom"
}

enum AIModel: String, Codable, CaseIterable {
    // OpenAI Models
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo"
    case gpt35Turbo = "gpt-3.5-turbo"
    
    // Anthropic Models
    case claude3Opus = "claude-3-opus"
    case claude3Sonnet = "claude-3-sonnet"
    case claude3Haiku = "claude-3-haiku"
    
    // Custom Model
    case custom = "custom"
    
    var provider: AIProvider {
        switch self {
        case .gpt4, .gpt4Turbo, .gpt35Turbo:
            return .openAI
        case .claude3Opus, .claude3Sonnet, .claude3Haiku:
            return .anthropic
        case .custom:
            return .custom
        }
    }
}

@Model
final class AIModelConfig {
    var id: UUID
    var name: String
    var provider: String // Using String to store AIProvider enum value for SwiftData compatibility
    var model: String // Using String to store AIModel enum value for SwiftData compatibility
    var temperature: Double
    var maxTokens: Int
    var isDefault: Bool
    var apiEndpoint: String?
    
    var providerType: AIProvider {
        return AIProvider(rawValue: provider) ?? .openAI
    }
    
    var modelType: AIModel {
        return AIModel(rawValue: model) ?? .gpt35Turbo
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         provider: AIProvider, 
         model: AIModel, 
         temperature: Double = 0.7, 
         maxTokens: Int = 1000, 
         isDefault: Bool = false,
         apiEndpoint: String? = nil) {
        self.id = id
        self.name = name
        self.provider = provider.rawValue
        self.model = model.rawValue
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.isDefault = isDefault
        self.apiEndpoint = apiEndpoint
    }
}

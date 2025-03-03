//
//  AIModelConfigViewModel.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData
import SwiftUI

class AIModelConfigViewModel: ObservableObject {
    private var modelContext: ModelContext
    
    @Published var configurations: [AIModelConfig] = []
    @Published var selectedConfig: AIModelConfig?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadConfigurations()
    }
    
    func loadConfigurations() {
        do {
            let descriptor = FetchDescriptor<AIModelConfig>(sortBy: [SortDescriptor(\.name)])
            configurations = try modelContext.fetch(descriptor)
            
            // Create default configurations if none exist
            if configurations.isEmpty {
                createDefaultConfigurations()
            }
        } catch {
            print("Error fetching AI model configurations: \(error)")
        }
    }
    
    private func createDefaultConfigurations() {
        let defaultConfigs = [
            AIModelConfig(name: "GPT-3.5 Turbo", provider: .openAI, model: .gpt35Turbo, isDefault: true),
            AIModelConfig(name: "GPT-4", provider: .openAI, model: .gpt4),
            AIModelConfig(name: "Claude 3 Haiku", provider: .anthropic, model: .claude3Haiku)
        ]
        
        for config in defaultConfigs {
            modelContext.insert(config)
        }
        
        do {
            try modelContext.save()
            loadConfigurations()
        } catch {
            print("Error saving default configurations: \(error)")
        }
    }
    
    func createConfiguration(
        name: String,
        provider: AIProvider,
        model: AIModel,
        temperature: Double = 0.7,
        maxTokens: Int = 1000,
        isDefault: Bool = false,
        apiEndpoint: String? = nil
    ) throws {
        guard !name.isEmpty else { throw NSError(domain: "AIModelConfig", code: 1, userInfo: [NSLocalizedDescriptionKey: "Name cannot be empty"]) }
        
        let config = AIModelConfig(
            name: name,
            provider: provider,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            isDefault: isDefault,
            apiEndpoint: apiEndpoint
        )
        
        if isDefault {
            // First, remove default status from all configurations
            for c in configurations {
                if c.isDefault {
                    c.isDefault = false
                }
            }
        }
        
        modelContext.insert(config)
        
        try modelContext.save()
        loadConfigurations()
    }
    
    func updateConfiguration(
        config: AIModelConfig,
        name: String,
        provider: AIProvider,
        model: AIModel,
        temperature: Double,
        maxTokens: Int,
        isDefault: Bool,
        apiEndpoint: String? = nil
    ) throws {
        guard !name.isEmpty else { throw NSError(domain: "AIModelConfig", code: 1, userInfo: [NSLocalizedDescriptionKey: "Name cannot be empty"]) }
        
        config.name = name
        config.provider = provider.rawValue
        config.model = model.rawValue
        config.temperature = temperature
        config.maxTokens = maxTokens
        
        if isDefault && !config.isDefault {
            // First, remove default status from all configurations
            for c in configurations {
                if c.isDefault {
                    c.isDefault = false
                }
            }
            config.isDefault = true
        }
        
        if provider == .custom {
            config.apiEndpoint = apiEndpoint
        } else {
            config.apiEndpoint = nil
        }
        
        try modelContext.save()
        selectedConfig = nil
        loadConfigurations()
    }
    
    func deleteConfig(_ config: AIModelConfig) {
        // Don't delete the default configuration
        if config.isDefault {
            return
        }
        
        modelContext.delete(config)
        
        do {
            try modelContext.save()
            loadConfigurations()
        } catch {
            print("Error deleting configuration: \(error)")
        }
    }
    
    func setDefaultConfig(_ config: AIModelConfig) {
        // First, remove default status from all configurations
        for c in configurations {
            if c.isDefault {
                c.isDefault = false
            }
        }
        
        // Set the selected configuration as default
        config.isDefault = true
        
        do {
            try modelContext.save()
            loadConfigurations()
        } catch {
            print("Error setting default configuration: \(error)")
        }
    }
    
    func getDefaultConfiguration() -> AIModelConfig? {
        return configurations.first(where: { $0.isDefault })
    }
    
    func getAvailableModels(for provider: AIProvider) -> [AIModel] {
        switch provider {
        case .openAI:
            return [.gpt4, .gpt4Turbo, .gpt35Turbo]
        case .anthropic:
            return [.claude3Opus, .claude3Sonnet, .claude3Haiku]
        case .custom:
            return [.custom]
        }
    }
}

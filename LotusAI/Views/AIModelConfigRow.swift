//
//  AIModelConfigRow.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI

struct AIModelConfigRow: View {
    let config: AIModelConfig
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(config.name)
                        .font(.headline)
                    
                    if config.isDefault {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("\(config.providerType.rawValue) - \(config.modelType.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Temperature: \(String(format: "%.1f", config.temperature))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AIModelConfigRow(config: AIModelConfig(
        name: "Default GPT-4",
        provider: .openAI,
        model: .gpt4,
        temperature: 0.7,
        maxTokens: 2000,
        isDefault: true
    ))
    .previewLayout(.sizeThatFits)
    .padding()
}

//
//  EditAIModelConfigView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI
import SwiftData

struct EditAIModelConfigView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: AIModelConfigViewModel
    var config: AIModelConfig
    
    @State private var name: String
    @State private var provider: AIProvider
    @State private var selectedModel: AIModel
    @State private var temperature: Double
    @State private var maxTokens: Int
    @State private var isDefault: Bool
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var apiEndpoint: String
    
    init(viewModel: AIModelConfigViewModel, config: AIModelConfig) {
        self.viewModel = viewModel
        self.config = config
        
        _name = State(initialValue: config.name)
        _provider = State(initialValue: config.providerType)
        _selectedModel = State(initialValue: config.modelType)
        _temperature = State(initialValue: config.temperature)
        _maxTokens = State(initialValue: config.maxTokens)
        _isDefault = State(initialValue: config.isDefault)
        _apiEndpoint = State(initialValue: config.apiEndpoint ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Configuration Name", text: $name)
                    
                    Picker("Provider", selection: $provider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    
                    if provider == .custom {
                        TextField("API Endpoint", text: $apiEndpoint)
                        Text("Custom model selected")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Model", selection: $selectedModel) {
                            ForEach(viewModel.getAvailableModels(for: provider), id: \.self) { model in
                                Text(model.rawValue).tag(model)
                            }
                        }
                        .onChange(of: provider) { oldValue, newValue in
                            let availableModels = viewModel.getAvailableModels(for: newValue)
                            if !availableModels.contains(selectedModel) && !availableModels.isEmpty {
                                selectedModel = availableModels[0]
                            }
                        }
                    }
                }
                
                Section(header: Text("Parameters")) {
                    VStack {
                        HStack {
                            Text("Temperature: \(String(format: "%.1f", temperature))")
                            Spacer()
                        }
                        Slider(value: $temperature, in: 0...1, step: 0.1)
                    }
                    
                    Stepper("Max Tokens: \(maxTokens)", value: $maxTokens, in: 100...8000, step: 100)
                }
                
                if !config.isDefault {
                    Section {
                        Toggle("Set as Default", isOn: $isDefault)
                    }
                }
            }
            .navigationTitle("Edit Model Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateConfig()
                    }
                    .disabled(name.isEmpty || (provider == .custom && apiEndpoint.isEmpty))
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateConfig() {
        do {
            let model = provider == .custom ? AIModel.custom : selectedModel
            
            try viewModel.updateConfiguration(
                config: config,
                name: name,
                provider: provider,
                model: model,
                temperature: temperature,
                maxTokens: maxTokens,
                isDefault: isDefault,
                apiEndpoint: provider == .custom ? apiEndpoint : nil
            )
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: AIModelConfig.self)
    let context = container.mainContext
    let viewModel = AIModelConfigViewModel(modelContext: context)
    
    return EditAIModelConfigView(
        viewModel: viewModel,
        config: AIModelConfig(
            name: "Default GPT-4",
            provider: .openAI,
            model: .gpt4,
            temperature: 0.7,
            maxTokens: 2000,
            isDefault: true
        )
    )
}

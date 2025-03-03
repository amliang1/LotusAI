//
//  SettingsView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var apiKey: String = ""
    @State private var isShowingAPIKey: Bool = false
    @State private var isValidating: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var selectedProvider: AIProvider = .openAI
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API Key")) {
                    Picker("Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .onChange(of: selectedProvider) { oldValue, newValue in
                        loadAPIKey()
                    }
                    
                    if isShowingAPIKey {
                        TextField("API Key", text: $apiKey)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("API Key", text: $apiKey)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    Toggle("Show API Key", isOn: $isShowingAPIKey)
                    
                    Button {
                        Task {
                            await validateAndSaveAPIKey()
                        }
                    } label: {
                        if isValidating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save API Key")
                        }
                    }
                    .disabled(apiKey.isEmpty || isValidating)
                }
                
                Section(header: Text("AI Assistant Configuration")) {
                    NavigationLink {
                        AIModelConfigView(modelContext: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "server.rack")
                            Text("AI Models")
                        }
                    }
                    
                    NavigationLink {
                        PromptLibraryView(modelContext: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "text.book.closed")
                            Text("Prompt Library")
                        }
                    }
                }
                
                Section(header: Text("Advanced Settings")) {
                    NavigationLink {
                        AdvancedSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.2")
                            Text("Advanced Settings")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadAPIKey()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func loadAPIKey() {
        do {
            let key = try KeychainManager.shared.getAPIKey(provider: selectedProvider.rawValue)
            apiKey = key
        } catch {
            // No API key found or error retrieving it
            apiKey = ""
        }
    }
    
    private func validateAndSaveAPIKey() async {
        isValidating = true
        
        do {
            let isValid = try await APIClient.shared.validateAPIKey(apiKey, provider: selectedProvider)
            
            if isValid {
                try KeychainManager.shared.saveAPIKey(apiKey, service: "LotusAI", account: selectedProvider.rawValue)
                alertTitle = "Success"
                alertMessage = "API key saved successfully."
            } else {
                alertTitle = "Error"
                alertMessage = "Invalid API key."
            }
        } catch {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
        }
        
        isValidating = false
        showAlert = true
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("enableDebugMode") private var enableDebugMode = false
    @AppStorage("enableInlineCommands") private var enableInlineCommands = true
    @AppStorage("enableCostEstimation") private var enableCostEstimation = true
    
    var body: some View {
        Form {
            Section(header: Text("Features")) {
                Toggle("Enable Inline Commands", isOn: $enableInlineCommands)
                Toggle("Enable Cost Estimation", isOn: $enableCostEstimation)
            }
            
            Section(header: Text("Developer Options")) {
                Toggle("Debug Mode", isOn: $enableDebugMode)
            }
        }
        .navigationTitle("Advanced Settings")
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AIModelConfig.self, PromptTemplate.self], inMemory: true)
}

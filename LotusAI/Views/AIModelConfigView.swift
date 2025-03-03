//
//  AIModelConfigView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI
import SwiftData

struct AIModelConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: AIModelConfigViewModel
    @State private var showingNewConfigSheet = false
    @State private var showingEditSheet = false
    
    init(modelContext: ModelContext? = nil) {
        let container = try! ModelContainer(for: AIModelConfig.self)
        let context = modelContext ?? container.mainContext
        _viewModel = StateObject(wrappedValue: AIModelConfigViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.configurations) { config in
                    AIModelConfigRow(config: config)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedConfig = config
                            showingEditSheet = true
                        }
                        .swipeActions {
                            if !config.isDefault {
                                Button {
                                    viewModel.setDefaultConfig(config)
                                } label: {
                                    Label("Set Default", systemImage: "star")
                                }
                                .tint(.yellow)
                            }
                            
                            Button(role: .destructive) {
                                viewModel.deleteConfig(config)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("AI Models")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewConfigSheet = true
                    } label: {
                        Label("Add Model", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewConfigSheet) {
                NewAIModelConfigView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedConfig) { config in
                EditAIModelConfigView(viewModel: viewModel, config: config)
            }
            .onAppear {
                viewModel.loadConfigurations()
            }
        }
    }
}




#Preview {
    AIModelConfigView()
}

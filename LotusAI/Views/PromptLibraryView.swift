//
//  PromptLibraryView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI
import SwiftData

struct PromptLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: PromptLibraryViewModel
    @State private var showingNewTemplateSheet = false
    @State private var showingEditSheet = false
    
    init(modelContext: ModelContext? = nil) {
        let container = try! ModelContainer(for: PromptTemplate.self)
        let context = modelContext ?? container.mainContext
        _viewModel = StateObject(wrappedValue: PromptLibraryViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.templates) { template in
                    PromptTemplateRow(template: template)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteTemplate(template)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.selectedTemplate = template
                                showingEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading) {
                            if !template.isDefault {
                                Button {
                                    viewModel.setDefaultTemplate(template)
                                } label: {
                                    Label("Set Default", systemImage: "star.fill")
                                }
                                .tint(.yellow)
                            }
                        }
                }
            }
            .navigationTitle("Prompt Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewTemplateSheet = true
                    } label: {
                        Label("Add Template", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTemplateSheet) {
                NewPromptTemplateView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditSheet) {
                if let template = viewModel.selectedTemplate {
                    EditPromptTemplateView(viewModel: viewModel, template: template)
                }
            }
            .onAppear {
                viewModel.loadTemplates()
            }
        }
    }
}

struct PromptTemplateRow: View {
    let template: PromptTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.title)
                    .font(.headline)
                
                Spacer()
                
                if template.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            Text(template.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text("Last updated: \(template.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NewPromptTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PromptLibraryViewModel
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Enter prompt template content...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.createTemplate(title: title, content: content)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

struct EditPromptTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PromptLibraryViewModel
    @State private var title: String
    @State private var content: String
    let template: PromptTemplate
    
    init(viewModel: PromptLibraryViewModel, template: PromptTemplate) {
        self.viewModel = viewModel
        self.template = template
        _title = State(initialValue: template.title)
        _content = State(initialValue: template.content)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Enter prompt template content...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                }
                
                if !template.isDefault {
                    Section {
                        Button {
                            viewModel.setDefaultTemplate(template)
                            dismiss()
                        } label: {
                            HStack {
                                Text("Set as Default")
                                Spacer()
                                Image(systemName: "star.fill")
                            }
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateTemplate(template: template, title: title, content: content)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    PromptLibraryView()
        .modelContainer(for: PromptTemplate.self, inMemory: true)
}

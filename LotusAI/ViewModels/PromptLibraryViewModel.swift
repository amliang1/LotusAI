//
//  PromptLibraryViewModel.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import SwiftData
import SwiftUI

class PromptLibraryViewModel: ObservableObject {
    private var modelContext: ModelContext
    
    @Published var templates: [PromptTemplate] = []
    @Published var selectedTemplate: PromptTemplate?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTemplates()
    }
    
    func loadTemplates() {
        do {
            let descriptor = FetchDescriptor<PromptTemplate>(sortBy: [SortDescriptor(\.title)])
            templates = try modelContext.fetch(descriptor)
            
            // Create default templates if none exist
            if templates.isEmpty {
                createDefaultTemplates()
            }
        } catch {
            print("Error fetching prompt templates: \(error)")
        }
    }
    
    private func createDefaultTemplates() {
        let defaultTemplates = [
            PromptTemplate(title: "General Assistant", content: "You are a helpful assistant. Provide clear and concise responses to the user's questions.", isDefault: true),
            PromptTemplate(title: "Code Reviewer", content: "You are a code review assistant. Analyze the code provided and suggest improvements, identify bugs, and explain best practices.", isDefault: false),
            PromptTemplate(title: "Writing Helper", content: "You are a writing assistant. Help the user improve their writing by suggesting edits, alternative phrasings, and providing feedback on clarity and style.", isDefault: false)
        ]
        
        for template in defaultTemplates {
            modelContext.insert(template)
        }
        
        do {
            try modelContext.save()
            loadTemplates()
        } catch {
            print("Error saving default templates: \(error)")
        }
    }
    
    func createTemplate(title: String, content: String) {
        guard !title.isEmpty, !content.isEmpty else { return }
        
        let template = PromptTemplate(title: title, content: content)
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            loadTemplates()
        } catch {
            print("Error saving new template: \(error)")
        }
    }
    
    func updateTemplate(template: PromptTemplate, title: String, content: String) {
        guard !title.isEmpty, !content.isEmpty else { return }
        
        template.title = title
        template.content = content
        template.updatedAt = Date()
        
        do {
            try modelContext.save()
            selectedTemplate = nil
            loadTemplates()
        } catch {
            print("Error updating template: \(error)")
        }
    }
    
    func deleteTemplate(_ template: PromptTemplate) {
        modelContext.delete(template)
        
        do {
            try modelContext.save()
            loadTemplates()
        } catch {
            print("Error deleting template: \(error)")
        }
    }
    
    func setDefaultTemplate(_ template: PromptTemplate) {
        // First, remove default status from all templates
        for t in templates {
            if t.isDefault {
                t.isDefault = false
            }
        }
        
        // Set the selected template as default
        template.isDefault = true
        
        do {
            try modelContext.save()
            loadTemplates()
        } catch {
            print("Error setting default template: \(error)")
        }
    }
}

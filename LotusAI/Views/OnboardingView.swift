//
//  OnboardingView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App logo/icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                // App title
                Text("Welcome to LotusAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // App description
                Text("Your AI-powered assistant that integrates with any app.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // API Key input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your API Key")
                        .font(.headline)
                    
                    SecureField("API Key", text: $viewModel.apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Continue button
                Button {
                    Task {
                        await viewModel.validateAPIKey()
                        if viewModel.isAPIKeyValid {
                            hasCompletedOnboarding = true
                        }
                    }
                } label: {
                    if viewModel.isValidating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .disabled(viewModel.apiKey.isEmpty || viewModel.isValidating)
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.checkForExistingAPIKey()
                if viewModel.isAPIKeyValid {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

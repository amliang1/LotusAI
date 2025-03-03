//
//  KeychainManager.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case noPassword
    }
    
    // Save API key to Keychain
    func saveAPIKey(_ apiKey: String, service: String = "LotusAI", account: String = "APIKey") throws {
        // Convert string to data
        let apiKeyData = apiKey.data(using: .utf8)!
        
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: apiKeyData
        ]
        
        // Delete any existing key before saving
        SecItemDelete(query as CFDictionary)
        
        // Add the key to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    // Retrieve API key from Keychain
    func getAPIKey(service: String = "LotusAI", account: String = "APIKey") throws -> String {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let data = result as? Data, let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.noPassword
        }
        
        return apiKey
    }
    
    // Convenience method to get API key for a specific provider
    func getAPIKey(provider: String) throws -> String {
        return try getAPIKey(service: "LotusAI", account: provider)
    }
    
    // Delete API key from Keychain
    func deleteAPIKey(service: String = "LotusAI", account: String = "APIKey") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    // Convenience method to delete API key for a specific provider
    func deleteAPIKey(provider: String) throws {
        try deleteAPIKey(service: "LotusAI", account: provider)
    }
}

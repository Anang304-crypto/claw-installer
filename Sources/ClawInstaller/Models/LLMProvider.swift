// LLMProvider — Simplified LLM provider model (3 options)

import Foundation
import SwiftUI

enum LLMProvider: String, CaseIterable, Identifiable {
    case anthropic  // Recommended - routes through Kimi Code API
    case google     // Free tier - Gemini Flash
    case ollama     // Local - requires detection
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .anthropic: return "Anthropic"
        case .google: return "Google AI"
        case .ollama: return "Ollama"
        }
    }
    
    var modelName: String {
        switch self {
        case .anthropic: return "Claude Sonnet"  // UI shows Claude, backend routes via Kimi
        case .google: return "Gemini Flash"
        case .ollama: return "Llama 3.2"
        }
    }
    
    var iconName: String {
        switch self {
        case .anthropic: return "brain.head.profile"
        case .google: return "sparkles"
        case .ollama: return "desktopcomputer"
        }
    }
    
    var color: Color {
        switch self {
        case .anthropic: return Color(red: 0.85, green: 0.55, blue: 0.35)
        case .google: return .blue
        case .ollama: return .purple
        }
    }
    
    var tagline: String {
        switch self {
        case .anthropic: return "Best for coding & reasoning"
        case .google: return "Free tier available"
        case .ollama: return "Run locally, 100% private"
        }
    }
    
    var badge: String? {
        switch self {
        case .anthropic: return "Recommended"
        case .google: return "Free"
        case .ollama: return "Local"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .anthropic: return .orange
        case .google: return .green
        case .ollama: return .purple
        }
    }
    
    var requiresAPIKey: Bool {
        switch self {
        case .anthropic, .google: return true
        case .ollama: return false
        }
    }
    
    var signupURL: URL {
        switch self {
        case .anthropic: return URL(string: "https://console.anthropic.com/")!
        case .google: return URL(string: "https://aistudio.google.com/")!
        case .ollama: return URL(string: "https://ollama.com/download")!
        }
    }
    
    var apiKeyURL: URL? {
        switch self {
        case .anthropic: return URL(string: "https://console.anthropic.com/settings/keys")
        case .google: return URL(string: "https://aistudio.google.com/app/apikey")
        case .ollama: return nil
        }
    }
    
    var keyPrefix: String {
        switch self {
        case .anthropic: return "sk-ant-"
        case .google: return "AIza"
        case .ollama: return ""
        }
    }
    
    var keyPattern: String {
        switch self {
        case .anthropic: return "^sk-ant-[a-zA-Z0-9_-]{90,}$"
        case .google: return "^AIza[a-zA-Z0-9_-]{35,}$"
        case .ollama: return ".*"
        }
    }
    
    var configKey: String {
        switch self {
        case .anthropic: return "ANTHROPIC_API_KEY"
        case .google: return "GOOGLE_API_KEY"
        case .ollama: return "OLLAMA_HOST"
        }
    }
    
    /// Backend model identifier (may differ from display name)
    var backendModel: String {
        switch self {
        case .anthropic: return "kimi-k2"  // Routes through Kimi Code API
        case .google: return "gemini-2.0-flash"
        case .ollama: return "llama3.2"
        }
    }
    
    var setupSteps: [LLMSetupStep] {
        switch self {
        case .anthropic:
            return [
                LLMSetupStep(
                    title: "Create Anthropic Account",
                    description: "Sign up at console.anthropic.com with your email or Google account.",
                    action: "Open Anthropic Console",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "Add Payment Method",
                    description: "Add a credit card to your account. New accounts get $5 free credit.",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "Create API Key",
                    description: "Go to Settings → API Keys → Create Key. Name it something memorable.",
                    action: "Open API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "Copy Your Key",
                    description: "Copy the key that starts with sk-ant-... and paste it below.",
                    action: nil,
                    url: nil
                ),
            ]
            
        case .google:
            return [
                LLMSetupStep(
                    title: "Open Google AI Studio",
                    description: "Sign in with your Google account at aistudio.google.com.",
                    action: "Open AI Studio",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "Get API Key",
                    description: "Click 'Get API Key' → 'Create API key in new project'.",
                    action: "Get API Key",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "Copy Your Key",
                    description: "Copy the key that starts with AIza... and paste it below.",
                    action: nil,
                    url: nil
                ),
            ]
            
        case .ollama:
            return [
                LLMSetupStep(
                    title: "Download Ollama",
                    description: "Download Ollama for macOS from ollama.com.",
                    action: "Download Ollama",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "Install & Run",
                    description: "Open the downloaded file and drag Ollama to Applications. Launch it from your menu bar.",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "Pull a Model",
                    description: "Open Terminal and run: ollama pull llama3.2",
                    action: nil,
                    url: nil
                ),
            ]
        }
    }
    
    func validateKeyFormat(_ key: String) -> Bool {
        if !requiresAPIKey { return true }
        guard let regex = try? NSRegularExpression(pattern: keyPattern) else { return false }
        let range = NSRange(key.startIndex..., in: key)
        return regex.firstMatch(in: key, range: range) != nil
    }
}

struct LLMSetupStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: String?
    let url: URL?
}

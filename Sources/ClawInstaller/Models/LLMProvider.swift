// LLMProvider — Model for LLM provider configuration

import Foundation
import SwiftUI

enum LLMProvider: String, CaseIterable, Identifiable {
    case anthropic
    case openai
    case google
    case deepseek
    case ollama
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .anthropic: return "Anthropic"
        case .openai: return "OpenAI"
        case .google: return "Google AI"
        case .deepseek: return "DeepSeek"
        case .ollama: return "Ollama"
        }
    }
    
    var bestModel: String {
        switch self {
        case .anthropic: return "Claude Sonnet 4"
        case .openai: return "GPT-4.1-mini"
        case .google: return "Gemini 2.5 Flash"
        case .deepseek: return "DeepSeek V3"
        case .ollama: return "Llama 3.2"
        }
    }
    
    var iconName: String {
        switch self {
        case .anthropic: return "brain.head.profile"
        case .openai: return "sparkles"
        case .google: return "globe"
        case .deepseek: return "water.waves"
        case .ollama: return "desktopcomputer"
        }
    }
    
    var color: Color {
        switch self {
        case .anthropic: return .orange
        case .openai: return .green
        case .google: return .blue
        case .deepseek: return .purple
        case .ollama: return .gray
        }
    }
    
    var signupURL: URL {
        switch self {
        case .anthropic: return URL(string: "https://console.anthropic.com/")!
        case .openai: return URL(string: "https://platform.openai.com/signup")!
        case .google: return URL(string: "https://aistudio.google.com/")!
        case .deepseek: return URL(string: "https://platform.deepseek.com/")!
        case .ollama: return URL(string: "https://ollama.com/download")!
        }
    }
    
    var apiKeyURL: URL? {
        switch self {
        case .anthropic: return URL(string: "https://console.anthropic.com/settings/keys")
        case .openai: return URL(string: "https://platform.openai.com/api-keys")
        case .google: return URL(string: "https://aistudio.google.com/app/apikey")
        case .deepseek: return URL(string: "https://platform.deepseek.com/api_keys")
        case .ollama: return nil // No API key needed
        }
    }
    
    var freeCredit: String {
        switch self {
        case .anthropic: return "$5 free"
        case .openai: return "$5 free"
        case .google: return "Generous free tier"
        case .deepseek: return "~$0.70 free"
        case .ollama: return "Unlimited (local)"
        }
    }
    
    var minTopup: String {
        switch self {
        case .anthropic: return "$5"
        case .openai: return "$5"
        case .google: return "$0"
        case .deepseek: return "~$0.70"
        case .ollama: return "$0"
        }
    }
    
    var monthlyEstimate: String {
        switch self {
        case .anthropic: return "~$3/mo typical"
        case .openai: return "~$2/mo typical"
        case .google: return "Often free"
        case .deepseek: return "~$0.50/mo typical"
        case .ollama: return "Free forever"
        }
    }
    
    var tagline: String {
        switch self {
        case .anthropic: return "Best quality & reasoning"
        case .openai: return "Most popular & versatile"
        case .google: return "Best free tier"
        case .deepseek: return "Cheapest paid option"
        case .ollama: return "Free, local, private"
        }
    }
    
    var requiresAPIKey: Bool {
        self != .ollama
    }
    
    var keyPrefix: String {
        switch self {
        case .anthropic: return "sk-ant-"
        case .openai: return "sk-"
        case .google: return "AIza"
        case .deepseek: return "sk-"
        case .ollama: return ""
        }
    }
    
    var keyPattern: String {
        switch self {
        case .anthropic: return "^sk-ant-[a-zA-Z0-9_-]{90,}$"
        case .openai: return "^sk-[a-zA-Z0-9_-]{40,}$"
        case .google: return "^AIza[a-zA-Z0-9_-]{35,}$"
        case .deepseek: return "^sk-[a-zA-Z0-9]{32,}$"
        case .ollama: return ".*"
        }
    }
    
    var configKey: String {
        switch self {
        case .anthropic: return "ANTHROPIC_API_KEY"
        case .openai: return "OPENAI_API_KEY"
        case .google: return "GOOGLE_API_KEY"
        case .deepseek: return "DEEPSEEK_API_KEY"
        case .ollama: return "OLLAMA_HOST"
        }
    }
    
    var testEndpoint: String {
        switch self {
        case .anthropic: return "https://api.anthropic.com/v1/messages"
        case .openai: return "https://api.openai.com/v1/chat/completions"
        case .google: return "https://generativelanguage.googleapis.com/v1beta/models"
        case .deepseek: return "https://api.deepseek.com/v1/chat/completions"
        case .ollama: return "http://localhost:11434/api/tags"
        }
    }
    
    var setupSteps: [SetupStep] {
        switch self {
        case .anthropic:
            return [
                SetupStep(title: "Create Account", description: "Sign up at console.anthropic.com with email or Google", action: "Open Anthropic Console", url: signupURL),
                SetupStep(title: "Add Payment", description: "Add a payment method (required even for free credit)", action: nil, url: nil),
                SetupStep(title: "Create API Key", description: "Go to Settings → API Keys → Create Key", action: "Open API Keys Page", url: apiKeyURL),
                SetupStep(title: "Copy Key", description: "Copy your new key — it starts with sk-ant-", action: nil, url: nil),
            ]
        case .openai:
            return [
                SetupStep(title: "Create Account", description: "Sign up at platform.openai.com", action: "Open OpenAI Platform", url: signupURL),
                SetupStep(title: "Add Payment", description: "Go to Billing → Add payment method", action: nil, url: nil),
                SetupStep(title: "Create API Key", description: "Go to API Keys → Create new secret key", action: "Open API Keys Page", url: apiKeyURL),
                SetupStep(title: "Copy Key", description: "Copy your key — it starts with sk-", action: nil, url: nil),
            ]
        case .google:
            return [
                SetupStep(title: "Open AI Studio", description: "Go to aistudio.google.com and sign in with Google", action: "Open Google AI Studio", url: signupURL),
                SetupStep(title: "Get API Key", description: "Click 'Get API Key' → Create in new project", action: "Open API Keys", url: apiKeyURL),
                SetupStep(title: "Copy Key", description: "Copy your key — it starts with AIza", action: nil, url: nil),
            ]
        case .deepseek:
            return [
                SetupStep(title: "Create Account", description: "Sign up at platform.deepseek.com", action: "Open DeepSeek", url: signupURL),
                SetupStep(title: "Top Up Balance", description: "Add minimum ~$0.70 (¥5) to your account", action: nil, url: nil),
                SetupStep(title: "Create API Key", description: "Go to API Keys → Create new key", action: "Open API Keys", url: apiKeyURL),
                SetupStep(title: "Copy Key", description: "Copy your key — it starts with sk-", action: nil, url: nil),
            ]
        case .ollama:
            return [
                SetupStep(title: "Download Ollama", description: "Download and install Ollama for macOS", action: "Download Ollama", url: signupURL),
                SetupStep(title: "Install Ollama", description: "Open the downloaded file and drag to Applications", action: nil, url: nil),
                SetupStep(title: "Run Ollama", description: "Open Ollama from Applications — it runs in menu bar", action: nil, url: nil),
                SetupStep(title: "Pull a Model", description: "Open Terminal and run: ollama pull llama3.2", action: nil, url: nil),
            ]
        }
    }
    
    struct SetupStep {
        let title: String
        let description: String
        let action: String?
        let url: URL?
    }
    
    func validateKeyFormat(_ key: String) -> Bool {
        if !requiresAPIKey { return true }
        guard let regex = try? NSRegularExpression(pattern: keyPattern) else { return false }
        let range = NSRange(key.startIndex..., in: key)
        return regex.firstMatch(in: key, range: range) != nil
    }
}

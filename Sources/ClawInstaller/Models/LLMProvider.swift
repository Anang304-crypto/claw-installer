// LLMProvider — Tiered LLM provider model (12 options, 4 tiers)

import Foundation
import SwiftUI

// MARK: - Provider Tier

enum ProviderTier: String, CaseIterable {
    case mainstream    // Tier 1 — International mainstream
    case multiModel    // Tier 2 — One key, many models
    case asia          // Tier 3 — Asia / China providers
    case local         // Tier 4 — Local / self-hosted

    var displayName: String {
        switch self {
        case .mainstream: return "國際主流"
        case .multiModel: return "一鍵多模型"
        case .asia: return "亞洲/中國供應商"
        case .local: return "本地/自架"
        }
    }

    var sectionIcon: String {
        switch self {
        case .mainstream: return "★"
        case .multiModel: return "⚡"
        case .asia: return "🌏"
        case .local: return "🖥️"
        }
    }
}

// MARK: - Auth Method

enum AuthMethod {
    case apiKey
    case oauth
    case none
}

// MARK: - LLM Provider

enum LLMProvider: String, CaseIterable, Identifiable {
    // Tier 1 — International mainstream
    case anthropic
    case openai
    case google

    // Tier 2 — One key, many models
    case openrouter
    case githubCopilot

    // Tier 3 — Asia / China providers
    case kimi
    case qwen
    case deepseek
    case minimax

    // Tier 4 — Local / self-hosted
    case ollama
    case custom

    var id: String { rawValue }

    // MARK: - Tier

    var tier: ProviderTier {
        switch self {
        case .anthropic, .openai, .google:
            return .mainstream
        case .openrouter, .githubCopilot:
            return .multiModel
        case .kimi, .qwen, .deepseek, .minimax:
            return .asia
        case .ollama, .custom:
            return .local
        }
    }

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .anthropic:    return "Anthropic"
        case .openai:       return "OpenAI"
        case .google:       return "Google AI"
        case .openrouter:   return "OpenRouter"
        case .githubCopilot: return "GitHub Copilot"
        case .kimi:         return "Kimi"
        case .qwen:         return "通義千問"
        case .deepseek:     return "DeepSeek"
        case .minimax:      return "MiniMax"
        case .ollama:       return "Ollama"
        case .custom:       return "自訂端點"
        }
    }

    var modelName: String {
        switch self {
        case .anthropic:    return "Claude Sonnet 4.5"
        case .openai:       return "GPT-5"
        case .google:       return "Gemini Flash"
        case .openrouter:   return "100+ 模型"
        case .githubCopilot: return "Copilot"
        case .kimi:         return "Kimi K2"
        case .qwen:         return "Qwen Max"
        case .deepseek:     return "DeepSeek V3"
        case .minimax:      return "MiniMax-01"
        case .ollama:       return "Llama 3.2"
        case .custom:       return "自訂模型"
        }
    }

    var tagline: String {
        switch self {
        case .anthropic:    return "程式與推理能力最強"
        case .openai:       return "Codex 訂閱制，GPT-5 旗艦"
        case .google:       return "免費額度，速度快"
        case .openrouter:   return "一把金鑰用遍百種模型"
        case .githubCopilot: return "GitHub OAuth 登入即用"
        case .kimi:         return "月之暗面，長上下文之王"
        case .qwen:         return "阿里雲，中文理解力優秀"
        case .deepseek:     return "高性價比，開源標竿"
        case .minimax:      return "多模態，語音/視覺整合"
        case .ollama:       return "完全離線，100% 隱私"
        case .custom:       return "自訂 OpenAI 相容端點"
        }
    }

    var iconName: String {
        switch self {
        case .anthropic:    return "brain.head.profile"
        case .openai:       return "sparkle"
        case .google:       return "sparkles"
        case .openrouter:   return "arrow.triangle.branch"
        case .githubCopilot: return "chevron.left.forwardslash.chevron.right"
        case .kimi:         return "moon.fill"
        case .qwen:         return "cloud.fill"
        case .deepseek:     return "magnifyingglass"
        case .minimax:      return "waveform"
        case .ollama:       return "desktopcomputer"
        case .custom:       return "slider.horizontal.3"
        }
    }

    var color: Color {
        switch self {
        case .anthropic:    return Color(red: 0.85, green: 0.55, blue: 0.35) // Anthropic orange-brown
        case .openai:       return Color(red: 0.00, green: 0.65, blue: 0.52) // OpenAI teal
        case .google:       return .blue
        case .openrouter:   return Color(red: 0.60, green: 0.40, blue: 0.90) // Purple
        case .githubCopilot: return Color(red: 0.14, green: 0.14, blue: 0.14) // GitHub dark
        case .kimi:         return Color(red: 0.30, green: 0.30, blue: 0.80) // Moonshot blue
        case .qwen:         return Color(red: 0.20, green: 0.50, blue: 0.85) // Alibaba blue
        case .deepseek:     return Color(red: 0.10, green: 0.55, blue: 0.85) // DeepSeek blue
        case .minimax:      return Color(red: 0.85, green: 0.30, blue: 0.30) // MiniMax red
        case .ollama:       return .purple
        case .custom:       return .gray
        }
    }

    // MARK: - Auth & Key

    var authMethod: AuthMethod {
        switch self {
        case .githubCopilot:
            return .oauth
        case .ollama, .custom:
            return .none
        default:
            return .apiKey
        }
    }

    var requiresAPIKey: Bool {
        authMethod == .apiKey
    }

    var keyPrefix: String {
        switch self {
        case .anthropic:    return "sk-ant-"
        case .openai:       return "sk-"
        case .google:       return "AIza"
        case .openrouter:   return "sk-or-"
        case .kimi:         return "sk-"
        case .qwen:         return "sk-"
        case .deepseek:     return "sk-"
        case .minimax:      return ""
        default:            return ""
        }
    }

    var keyPattern: String {
        switch self {
        case .anthropic:    return "^sk-ant-[a-zA-Z0-9_-]{90,}$"
        case .openai:       return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .google:       return "^AIza[a-zA-Z0-9_-]{35,}$"
        case .openrouter:   return "^sk-or-[a-zA-Z0-9_-]{30,}$"
        case .kimi:         return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .qwen:         return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .deepseek:     return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .minimax:      return "^[a-zA-Z0-9_-]{20,}$"
        default:            return ".*"
        }
    }

    var configKey: String {
        switch self {
        case .anthropic:    return "ANTHROPIC_API_KEY"
        case .openai:       return "OPENAI_API_KEY"
        case .google:       return "GOOGLE_API_KEY"
        case .openrouter:   return "OPENROUTER_API_KEY"
        case .githubCopilot: return "GITHUB_TOKEN"
        case .kimi:         return "MOONSHOT_API_KEY"
        case .qwen:         return "DASHSCOPE_API_KEY"
        case .deepseek:     return "DEEPSEEK_API_KEY"
        case .minimax:      return "MINIMAX_API_KEY"
        case .ollama:       return "OLLAMA_HOST"
        case .custom:       return "CUSTOM_API_KEY"
        }
    }

    /// Backend model identifier (may differ from display name)
    var backendModel: String {
        switch self {
        case .anthropic:    return "claude-sonnet-4-5-20250514"
        case .openai:       return "gpt-5"
        case .google:       return "gemini-2.0-flash"
        case .openrouter:   return "openrouter/auto"
        case .githubCopilot: return "copilot"
        case .kimi:         return "kimi-k2"
        case .qwen:         return "qwen-max"
        case .deepseek:     return "deepseek-chat"
        case .minimax:      return "MiniMax-Text-01"
        case .ollama:       return "llama3.2"
        case .custom:       return "custom"
        }
    }

    // MARK: - Badge

    var badgeText: String? {
        switch self {
        case .anthropic:    return "推薦"
        case .openai:       return "Codex"
        case .google:       return "Free"
        case .openrouter:   return "100+"
        case .githubCopilot: return "OAuth"
        case .deepseek:     return "CP 值王"
        case .ollama:       return "Local"
        case .custom:       return "Custom"
        default:            return nil
        }
    }

    var badgeColor: Color {
        switch self {
        case .anthropic:    return .orange
        case .openai:       return Color(red: 0.00, green: 0.65, blue: 0.52)
        case .google:       return .green
        case .openrouter:   return Color(red: 0.60, green: 0.40, blue: 0.90)
        case .githubCopilot: return .gray
        case .deepseek:     return Color(red: 0.10, green: 0.55, blue: 0.85)
        case .ollama:       return .purple
        case .custom:       return .gray
        default:            return .secondary
        }
    }

    // MARK: - URLs

    var signupURL: URL {
        switch self {
        case .anthropic:    return URL(string: "https://console.anthropic.com/")!
        case .openai:       return URL(string: "https://platform.openai.com/signup")!
        case .google:       return URL(string: "https://aistudio.google.com/")!
        case .openrouter:   return URL(string: "https://openrouter.ai/")!
        case .githubCopilot: return URL(string: "https://github.com/settings/copilot")!
        case .kimi:         return URL(string: "https://platform.moonshot.cn/")!
        case .qwen:         return URL(string: "https://dashscope.console.aliyun.com/")!
        case .deepseek:     return URL(string: "https://platform.deepseek.com/")!
        case .minimax:      return URL(string: "https://www.minimaxi.com/")!
        case .ollama:       return URL(string: "https://ollama.com/download")!
        case .custom:       return URL(string: "https://github.com/clawinstaller/claw-installer")!
        }
    }

    var apiKeyURL: URL? {
        switch self {
        case .anthropic:    return URL(string: "https://console.anthropic.com/settings/keys")
        case .openai:       return URL(string: "https://platform.openai.com/api-keys")
        case .google:       return URL(string: "https://aistudio.google.com/app/apikey")
        case .openrouter:   return URL(string: "https://openrouter.ai/keys")
        case .kimi:         return URL(string: "https://platform.moonshot.cn/console/api-keys")
        case .qwen:         return URL(string: "https://dashscope.console.aliyun.com/apiKey")
        case .deepseek:     return URL(string: "https://platform.deepseek.com/api_keys")
        case .minimax:      return URL(string: "https://www.minimaxi.com/platform")
        default:            return nil
        }
    }

    // MARK: - Setup Steps

    var setupSteps: [LLMSetupStep] {
        switch self {
        case .anthropic:
            return [
                LLMSetupStep(
                    title: "建立 Anthropic 帳號",
                    description: "前往 console.anthropic.com，使用 Email 或 Google 帳號註冊。",
                    action: "開啟 Anthropic Console",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "新增付款方式",
                    description: "在帳號設定中新增信用卡。新帳號可獲得 $5 免費額度。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "建立 API 金鑰",
                    description: "前往 Settings → API Keys → Create Key，為金鑰取一個好記的名稱。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-ant-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .openai:
            return [
                LLMSetupStep(
                    title: "建立 OpenAI 帳號",
                    description: "前往 platform.openai.com，使用 Email 或 Google 帳號註冊。",
                    action: "開啟 OpenAI Platform",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "新增付款方式",
                    description: "在 Billing 頁面新增信用卡並儲值。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "建立 API 金鑰",
                    description: "前往 API Keys 頁面，點選 Create new secret key。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .google:
            return [
                LLMSetupStep(
                    title: "開啟 Google AI Studio",
                    description: "使用 Google 帳號登入 aistudio.google.com。",
                    action: "開啟 AI Studio",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "點選 Get API Key → Create API key in new project。",
                    action: "取得 API Key",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 AIza... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .openrouter:
            return [
                LLMSetupStep(
                    title: "建立 OpenRouter 帳號",
                    description: "前往 openrouter.ai，支援 Google / GitHub 登入。",
                    action: "開啟 OpenRouter",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 Keys 頁面，建立新金鑰。一把金鑰即可使用所有模型。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-or-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .githubCopilot:
            return [
                LLMSetupStep(
                    title: "啟用 GitHub Copilot",
                    description: "前往 GitHub Settings → Copilot，確認已啟用訂閱。",
                    action: "開啟 Copilot 設定",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "授權登入",
                    description: "點選下方按鈕透過 GitHub OAuth 授權，無需手動輸入金鑰。",
                    action: nil,
                    url: nil
                ),
            ]

        case .kimi:
            return [
                LLMSetupStep(
                    title: "建立 Moonshot 帳號",
                    description: "前往 platform.moonshot.cn，使用手機號碼或 Email 註冊。",
                    action: "開啟 Moonshot Platform",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 API Keys 管理頁面，建立新金鑰。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .qwen:
            return [
                LLMSetupStep(
                    title: "建立阿里雲帳號",
                    description: "前往 DashScope 控制台，使用阿里雲帳號登入。",
                    action: "開啟 DashScope",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 API Key 管理頁面，建立新金鑰。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .deepseek:
            return [
                LLMSetupStep(
                    title: "建立 DeepSeek 帳號",
                    description: "前往 platform.deepseek.com，註冊帳號。",
                    action: "開啟 DeepSeek Platform",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 API Keys 頁面，建立新金鑰。新帳號有免費額度。",
                    action: "開啟 API Keys",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製以 sk-... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .minimax:
            return [
                LLMSetupStep(
                    title: "建立 MiniMax 帳號",
                    description: "前往 minimaxi.com，註冊開發者帳號。",
                    action: "開啟 MiniMax",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 Platform 管理頁面，建立新金鑰。",
                    action: "開啟 Platform",
                    url: apiKeyURL
                ),
                LLMSetupStep(
                    title: "複製你的金鑰",
                    description: "複製金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]

        case .ollama:
            return [
                LLMSetupStep(
                    title: "下載 Ollama",
                    description: "從 ollama.com 下載 macOS 版本。",
                    action: "下載 Ollama",
                    url: signupURL
                ),
                LLMSetupStep(
                    title: "安裝並啟動",
                    description: "打開下載的檔案，將 Ollama 拖到應用程式資料夾。從選單列啟動它。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "拉取模型",
                    description: "開啟終端機並執行：ollama pull llama3.2",
                    action: nil,
                    url: nil
                ),
            ]

        case .custom:
            return [
                LLMSetupStep(
                    title: "準備端點資訊",
                    description: "確認你的 OpenAI 相容 API 端點 URL 和金鑰（如有需要）。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "輸入設定",
                    description: "在下方輸入端點 URL 和 API 金鑰。",
                    action: nil,
                    url: nil
                ),
            ]
        }
    }

    // MARK: - Validation

    func validateKeyFormat(_ key: String) -> Bool {
        if !requiresAPIKey { return true }
        guard let regex = try? NSRegularExpression(pattern: keyPattern) else { return false }
        let range = NSRange(key.startIndex..., in: key)
        return regex.firstMatch(in: key, range: range) != nil
    }

    // MARK: - Helpers

    /// Get all providers for a given tier
    static func providers(for tier: ProviderTier) -> [LLMProvider] {
        allCases.filter { $0.tier == tier }
    }
}

// MARK: - Setup Step Model

struct LLMSetupStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: String?
    let url: URL?
}

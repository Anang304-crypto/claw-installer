// LLMProvider — 6 providers, 2 tiers, multi-auth choices (matches OpenClaw onboard flow)

import Foundation
import SwiftUI

// MARK: - Provider Tier

enum ProviderTier: String, CaseIterable {
    case mainstream    // Tier 1 — International mainstream
    case asia          // Tier 2 — Asia / China providers

    var displayName: String {
        switch self {
        case .mainstream: return "國際主流"
        case .asia: return "亞洲供應商"
        }
    }

    var sectionIcon: String {
        switch self {
        case .mainstream: return "★"
        case .asia: return "🌏"
        }
    }
}

// MARK: - Auth Method

enum AuthMethod: String {
    case apiKey = "api_key"
    case setupToken = "token"
    case oauth = "oauth"
    case deviceCode = "device_code"
    case none = "none"
}

// MARK: - Auth Choice (matches OpenClaw AUTH_CHOICE_GROUP_DEFS)

struct AuthChoice: Identifiable {
    let id: String       // e.g. "token", "apiKey", "openai-codex"
    let label: String    // e.g. "Setup Token (貼上 token)"
    let hint: String?    // e.g. "執行 claude setup-token 取得"
    let method: AuthMethod
    let isRecommended: Bool

    init(id: String, label: String, hint: String? = nil, method: AuthMethod, isRecommended: Bool = false) {
        self.id = id
        self.label = label
        self.hint = hint
        self.method = method
        self.isRecommended = isRecommended
    }
}

// MARK: - Model Option

struct ModelOption: Identifiable {
    let id: String       // e.g. "anthropic/claude-sonnet-4-5"
    let displayName: String
    let hint: String?    // e.g. "推薦 · 平衡性能與成本"
    let isDefault: Bool

    init(id: String, displayName: String, hint: String? = nil, isDefault: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.hint = hint
        self.isDefault = isDefault
    }
}

// MARK: - LLM Provider

enum LLMProvider: String, CaseIterable, Identifiable {
    // Tier 1 — International mainstream
    case anthropic
    case openai
    case google

    // Tier 2 — Asia / China providers
    case kimi
    case qwen
    case minimax

    var id: String { rawValue }

    // MARK: - Tier

    var tier: ProviderTier {
        switch self {
        case .anthropic, .openai, .google:
            return .mainstream
        case .kimi, .qwen, .minimax:
            return .asia
        }
    }

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .anthropic:    return "Anthropic"
        case .openai:       return "OpenAI"
        case .google:       return "Google"
        case .kimi:         return "Kimi 月之暗面"
        case .qwen:         return "Qwen 通義千問"
        case .minimax:      return "MiniMax"
        }
    }

    var modelName: String {
        switch self {
        case .anthropic:    return "Claude Sonnet 4.5"
        case .openai:       return "GPT-5.2"
        case .google:       return "Gemini 2.5 Flash"
        case .kimi:         return "Kimi K2.5"
        case .qwen:         return "Qwen Coder"
        case .minimax:      return "MiniMax M2.5"
        }
    }

    var tagline: String {
        switch self {
        case .anthropic:    return "Token / API Key"
        case .openai:       return "OAuth / API Key"
        case .google:       return "API Key / OAuth · 免費額度"
        case .kimi:         return "API Key · 高性價比"
        case .qwen:         return "API Key · 免費額度"
        case .minimax:      return "API Key"
        }
    }

    var iconName: String {
        switch self {
        case .anthropic:    return "brain.head.profile"
        case .openai:       return "sparkle"
        case .google:       return "sparkles"
        case .kimi:         return "moon.fill"
        case .qwen:         return "cloud.fill"
        case .minimax:      return "waveform"
        }
    }

    var color: Color {
        switch self {
        case .anthropic:    return Color(red: 0.85, green: 0.55, blue: 0.35)
        case .openai:       return Color(red: 0.00, green: 0.65, blue: 0.52)
        case .google:       return .blue
        case .kimi:         return Color(red: 0.30, green: 0.30, blue: 0.80)
        case .qwen:         return Color(red: 0.20, green: 0.50, blue: 0.85)
        case .minimax:      return Color(red: 0.85, green: 0.30, blue: 0.30)
        }
    }

    // MARK: - Auth Choices (matches OpenClaw AUTH_CHOICE_GROUP_DEFS)

    var authChoices: [AuthChoice] {
        switch self {
        case .anthropic:
            return [
                AuthChoice(
                    id: "token",
                    label: "Setup Token（貼上 token）",
                    hint: "在終端機執行 claude setup-token，然後貼上 token",
                    method: .setupToken,
                    isRecommended: true
                ),
                AuthChoice(
                    id: "apiKey",
                    label: "API Key",
                    hint: "從 console.anthropic.com 取得",
                    method: .apiKey
                ),
            ]
        case .openai:
            return [
                AuthChoice(
                    id: "openai-codex",
                    label: "ChatGPT 帳號登入（OAuth）",
                    hint: "使用 ChatGPT 帳號授權，免 API Key",
                    method: .deviceCode,
                    isRecommended: true
                ),
                AuthChoice(
                    id: "openai-api-key",
                    label: "API Key",
                    hint: "從 platform.openai.com 取得",
                    method: .apiKey
                ),
            ]
        case .google:
            return [
                AuthChoice(
                    id: "gemini-api-key",
                    label: "API Key",
                    hint: "從 aistudio.google.com 取得，有免費額度",
                    method: .apiKey,
                    isRecommended: true
                ),
                AuthChoice(
                    id: "google-gemini-cli",
                    label: "Google 帳號登入（OAuth）",
                    hint: "使用 Google 帳號授權，免 API Key",
                    method: .deviceCode
                ),
            ]
        case .kimi:
            return [
                AuthChoice(
                    id: "kimi-api-key",
                    label: "API Key",
                    hint: "從 platform.moonshot.cn 取得",
                    method: .apiKey,
                    isRecommended: true
                ),
            ]
        case .qwen:
            return [
                AuthChoice(
                    id: "qwen-api-key",
                    label: "API Key",
                    hint: "從 DashScope 控制台取得",
                    method: .apiKey,
                    isRecommended: true
                ),
            ]
        case .minimax:
            return [
                AuthChoice(
                    id: "minimax-api-key",
                    label: "API Key",
                    hint: "從 minimaxi.com 取得",
                    method: .apiKey,
                    isRecommended: true
                ),
            ]
        }
    }

    /// Default auth choice (first recommended, or first)
    var defaultAuthChoice: AuthChoice {
        authChoices.first(where: { $0.isRecommended }) ?? authChoices[0]
    }

    // MARK: - Model Options (matches OpenClaw model allowlist)

    var modelOptions: [ModelOption] {
        switch self {
        case .anthropic:
            return [
                ModelOption(id: "anthropic/claude-sonnet-4-5", displayName: "Claude Sonnet 4.5", hint: "推薦 · 平衡性能與成本", isDefault: true),
                ModelOption(id: "anthropic/claude-opus-4", displayName: "Claude Opus 4", hint: "最強推理"),
                ModelOption(id: "anthropic/claude-haiku-3-5", displayName: "Claude Haiku 3.5", hint: "最快速度"),
            ]
        case .openai:
            return [
                ModelOption(id: "openai/gpt-4.1", displayName: "GPT-4.1", hint: "推薦 · 高性能", isDefault: true),
                ModelOption(id: "openai/o3-mini", displayName: "o3-mini", hint: "推理模型"),
                ModelOption(id: "openai/gpt-4.1-mini", displayName: "GPT-4.1 Mini", hint: "經濟實惠"),
            ]
        case .google:
            return [
                ModelOption(id: "google/gemini-2.5-flash", displayName: "Gemini 2.5 Flash", hint: "推薦 · 免費額度", isDefault: true),
                ModelOption(id: "google/gemini-2.5-pro", displayName: "Gemini 2.5 Pro", hint: "最強性能"),
            ]
        case .kimi:
            return [
                ModelOption(id: "kimi/kimi-k2", displayName: "Kimi K2", hint: "推薦", isDefault: true),
            ]
        case .qwen:
            return [
                ModelOption(id: "qwen/qwen-max", displayName: "Qwen Max", hint: "推薦", isDefault: true),
                ModelOption(id: "qwen/qwen-plus", displayName: "Qwen Plus", hint: "經濟實惠"),
            ]
        case .minimax:
            return [
                ModelOption(id: "minimax/MiniMax-M1", displayName: "MiniMax M1", hint: "推薦", isDefault: true),
            ]
        }
    }

    /// Default model for this provider
    var defaultModel: ModelOption {
        modelOptions.first(where: { $0.isDefault }) ?? modelOptions[0]
    }

    /// Suggested failover model (free/cheap fallback when primary is unavailable)
    var failoverModel: ModelOption? {
        switch self {
        case .anthropic:
            return ModelOption(id: "google/gemini-2.5-flash", displayName: "Google Gemini Flash", hint: "免費")
        case .openai:
            return ModelOption(id: "google/gemini-2.5-flash", displayName: "Google Gemini Flash", hint: "免費")
        case .kimi, .qwen, .minimax:
            return ModelOption(id: "google/gemini-2.5-flash", displayName: "Google Gemini Flash", hint: "免費")
        case .google:
            return nil // Google itself is the free option
        }
    }

    // MARK: - Auth & Key

    var authMethod: AuthMethod {
        defaultAuthChoice.method
    }

    var requiresAPIKey: Bool {
        authChoices.contains(where: { $0.method == .apiKey })
    }

    var keyPrefix: String {
        switch self {
        case .anthropic:    return "sk-ant-"
        case .openai:       return "sk-"
        case .google:       return "AIza"
        case .kimi:         return "sk-"
        case .qwen:         return "sk-"
        case .minimax:      return ""
        }
    }

    var keyPattern: String {
        switch self {
        case .anthropic:    return "^sk-ant-[a-zA-Z0-9_-]{90,}$"
        case .openai:       return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .google:       return "^AIza[a-zA-Z0-9_-]{35,}$"
        case .kimi:         return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .qwen:         return "^sk-[a-zA-Z0-9_-]{30,}$"
        case .minimax:      return "^[a-zA-Z0-9_-]{20,}$"
        }
    }

    var configKey: String {
        switch self {
        case .anthropic:    return "ANTHROPIC_API_KEY"
        case .openai:       return "OPENAI_API_KEY"
        case .google:       return "GOOGLE_API_KEY"
        case .kimi:         return "MOONSHOT_API_KEY"
        case .qwen:         return "DASHSCOPE_API_KEY"
        case .minimax:      return "MINIMAX_API_KEY"
        }
    }

    /// Backend model identifier
    var backendModel: String {
        defaultModel.id
    }

    // MARK: - Badge

    var badgeText: String? {
        switch self {
        case .anthropic:    return "推薦"
        case .google:       return "免費"
        default:            return nil
        }
    }

    var badgeColor: Color {
        switch self {
        case .anthropic:    return .orange
        case .google:       return .green
        default:            return .secondary
        }
    }

    // MARK: - URLs

    var signupURL: URL {
        switch self {
        case .anthropic:    return URL(string: "https://console.anthropic.com/")!
        case .openai:       return URL(string: "https://platform.openai.com/signup")!
        case .google:       return URL(string: "https://aistudio.google.com/")!
        case .kimi:         return URL(string: "https://platform.moonshot.cn/")!
        case .qwen:         return URL(string: "https://dashscope.console.aliyun.com/")!
        case .minimax:      return URL(string: "https://www.minimaxi.com/")!
        }
    }

    var apiKeyURL: URL? {
        switch self {
        case .anthropic:    return URL(string: "https://console.anthropic.com/settings/keys")
        case .openai:       return URL(string: "https://platform.openai.com/api-keys")
        case .google:       return URL(string: "https://aistudio.google.com/app/apikey")
        case .kimi:         return URL(string: "https://platform.moonshot.cn/console/api-keys")
        case .qwen:         return URL(string: "https://dashscope.console.aliyun.com/apiKey")
        case .minimax:      return URL(string: "https://www.minimaxi.com/platform")
        }
    }

    // MARK: - Setup Steps (simplified — per auth choice)

    func setupSteps(for authChoice: AuthChoice) -> [LLMSetupStep] {
        switch authChoice.method {
        case .setupToken:
            return [
                LLMSetupStep(
                    title: "取得 Setup Token",
                    description: "在其他終端機執行 `claude setup-token`，按照指示完成登入。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "貼上 Token",
                    description: "複製產生的 token，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]
        case .deviceCode:
            return [
                LLMSetupStep(
                    title: "啟動授權流程",
                    description: "點「繼續」後，系統會自動執行授權指令。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "在瀏覽器登入",
                    description: "終端會產生一個授權連結，自動開啟瀏覽器。請用你的 \(displayName) 帳號登入並同意授權。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "等待完成",
                    description: "授權完成後，指令會自動偵測並寫入設定。你可以在 App 內看到即時進度。",
                    action: nil,
                    url: nil
                ),
            ]
        case .apiKey:
            return [
                LLMSetupStep(
                    title: "取得 API 金鑰",
                    description: "前往 \(displayName) 開發者控制台建立 API 金鑰。",
                    action: "開啟控制台",
                    url: apiKeyURL ?? signupURL
                ),
                LLMSetupStep(
                    title: "貼上金鑰",
                    description: keyPrefix.isEmpty
                        ? "複製金鑰，貼到下方欄位。"
                        : "複製以 \(keyPrefix)... 開頭的金鑰，貼到下方欄位。",
                    action: nil,
                    url: nil
                ),
            ]
        case .oauth:
            return [
                LLMSetupStep(
                    title: "啟動 OAuth 授權",
                    description: "點「繼續」後，系統會自動執行授權指令。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "在瀏覽器登入",
                    description: "瀏覽器會開啟 \(displayName) 登入頁面，請登入你的帳號並同意授權。",
                    action: nil,
                    url: nil
                ),
                LLMSetupStep(
                    title: "自動完成設定",
                    description: "授權成功後會自動寫入設定，App 內即時顯示進度。",
                    action: nil,
                    url: nil
                ),
            ]
        case .none:
            return []
        }
    }

    /// Legacy: default setup steps using recommended auth choice
    var setupSteps: [LLMSetupStep] {
        setupSteps(for: defaultAuthChoice)
    }

    // MARK: - Validation

    func validateKeyFormat(_ key: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: keyPattern) else { return false }
        let range = NSRange(key.startIndex..., in: key)
        return regex.firstMatch(in: key, range: range) != nil
    }

    /// Validate input based on auth method
    func validateInput(_ input: String, authChoice: AuthChoice) -> Bool {
        switch authChoice.method {
        case .setupToken:
            return input.count >= 20
        case .apiKey:
            return validateKeyFormat(input)
        case .deviceCode, .oauth:
            return true
        case .none:
            return true
        }
    }

    // MARK: - OpenClaw Onboard CLI Integration

    /// The `openclaw onboard` flag for this provider's API key (e.g. --anthropic-api-key)
    var onboardApiKeyFlag: String? {
        switch self {
        case .anthropic:    return "--anthropic-api-key"
        case .openai:       return "--openai-api-key"
        case .google:       return "--gemini-api-key"
        case .kimi:         return "--moonshot-api-key"
        case .qwen:         return nil // not in openclaw onboard flags
        case .minimax:      return "--minimax-api-key"
        }
    }

    /// The `--auth-choice` value for OAuth-based auth choices
    func onboardAuthChoiceValue(for authChoice: AuthChoice) -> String? {
        switch authChoice.id {
        case "token":               return "token"
        case "openai-codex":        return "openai-codex"
        case "google-gemini-cli":   return "google-gemini-cli"
        default:                    return nil
        }
    }

    /// The `--token-provider` value for setup-token flow
    var onboardTokenProvider: String? {
        switch self {
        case .anthropic:    return "anthropic"
        default:            return nil
        }
    }

    /// Build `openclaw onboard` arguments for non-interactive API key / token setup
    func onboardArgs(authChoice: AuthChoice, secret: String, modelId: String) -> [String] {
        var args = ["onboard", "--non-interactive", "--accept-risk", "--mode", "local"]

        switch authChoice.method {
        case .apiKey:
            if let flag = onboardApiKeyFlag {
                args += [flag, secret]
            }
        case .setupToken:
            args += ["--auth-choice", "token"]
            if let tp = onboardTokenProvider {
                args += ["--token-provider", tp]
            }
            args += ["--token", secret]
        case .deviceCode, .oauth:
            if let ac = onboardAuthChoiceValue(for: authChoice) {
                args += ["--auth-choice", ac]
            }
        case .none:
            break
        }

        return args
    }

    // MARK: - Helpers

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

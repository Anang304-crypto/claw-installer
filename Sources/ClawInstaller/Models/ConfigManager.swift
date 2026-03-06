// ConfigManager — Read/Write ~/.openclaw/openclaw.json

import Foundation

struct OpenClawConfig: Codable {
    var channels: ChannelsConfig?
    var gateway: GatewayConfig?
    var llm: LLMConfig?

    struct LLMConfig: Codable {
        var provider: String?
        var model: String?
        var displayModel: String?
    }
    var dmPolicy: String?

    struct ChannelsConfig: Codable {
        var telegram: TelegramConfig?
        var discord: DiscordConfig?
        var whatsapp: WhatsAppConfig?
        var line: LineConfig?
        var slack: SlackConfig?
        var teams: TeamsConfig?
    }

    struct TelegramConfig: Codable {
        var botToken: String?
        var allowedUsers: [Int64]?
    }

    struct DiscordConfig: Codable {
        var botToken: String?
        var applicationId: String?
        var allowedUsers: [String]?
    }

    struct WhatsAppConfig: Codable {
        var enabled: Bool?
        var sessionPath: String?
    }

    struct LineConfig: Codable {
        var channelAccessToken: String?
        var channelSecret: String?
    }

    struct SlackConfig: Codable {
        var botToken: String?
        var appToken: String?
    }

    struct TeamsConfig: Codable {
        var botToken: String?
        var tenantId: String?
    }

    struct GatewayConfig: Codable {
        var port: Int?
    }
}

@MainActor
class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    @Published var config: OpenClawConfig = OpenClawConfig()
    @Published var lastError: String?

    private let configDir: URL
    private let configFile: URL

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        configDir = home.appendingPathComponent(".openclaw")
        configFile = configDir.appendingPathComponent("openclaw.json")

        loadConfig()
    }

    func loadConfig() {
        guard FileManager.default.fileExists(atPath: configFile.path) else {
            config = OpenClawConfig()
            return
        }

        do {
            let data = try Data(contentsOf: configFile)
            let decoder = JSONDecoder()
            config = try decoder.decode(OpenClawConfig.self, from: data)
        } catch {
            lastError = "Failed to load config: \(error.localizedDescription)"
            config = OpenClawConfig()
        }
    }

    func saveConfig() throws {
        // Ensure directory exists
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: configFile)
    }

    // MARK: - DM Policy

    func setDMPolicy(_ policy: DMPolicy) throws {
        config.dmPolicy = policy.rawValue
        try saveConfig()
    }

    // MARK: - Telegram

    func setTelegramToken(_ token: String) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.telegram == nil {
            config.channels?.telegram = OpenClawConfig.TelegramConfig()
        }
        config.channels?.telegram?.botToken = token
        try saveConfig()
    }

    var hasTelegramConfig: Bool {
        config.channels?.telegram?.botToken?.isEmpty == false
    }

    // MARK: - Discord

    func setDiscordConfig(botToken: String, applicationId: String) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.discord == nil {
            config.channels?.discord = OpenClawConfig.DiscordConfig()
        }
        config.channels?.discord?.botToken = botToken
        config.channels?.discord?.applicationId = applicationId
        try saveConfig()
    }

    var hasDiscordConfig: Bool {
        config.channels?.discord?.botToken?.isEmpty == false
    }

    // MARK: - WhatsApp

    func setWhatsAppEnabled(_ enabled: Bool) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.whatsapp == nil {
            config.channels?.whatsapp = OpenClawConfig.WhatsAppConfig()
        }
        config.channels?.whatsapp?.enabled = enabled
        try saveConfig()
    }

    var hasWhatsAppConfig: Bool {
        config.channels?.whatsapp?.enabled == true
    }

    // MARK: - LINE

    func setLineConfig(channelAccessToken: String, channelSecret: String) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.line == nil {
            config.channels?.line = OpenClawConfig.LineConfig()
        }
        config.channels?.line?.channelAccessToken = channelAccessToken
        config.channels?.line?.channelSecret = channelSecret
        try saveConfig()
    }

    var hasLineConfig: Bool {
        config.channels?.line?.channelAccessToken?.isEmpty == false
    }

    // MARK: - Slack

    func setSlackConfig(botToken: String, appToken: String) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.slack == nil {
            config.channels?.slack = OpenClawConfig.SlackConfig()
        }
        config.channels?.slack?.botToken = botToken
        config.channels?.slack?.appToken = appToken
        try saveConfig()
    }

    var hasSlackConfig: Bool {
        config.channels?.slack?.botToken?.isEmpty == false
    }

    // MARK: - Teams

    func setTeamsConfig(botToken: String, tenantId: String) throws {
        if config.channels == nil {
            config.channels = OpenClawConfig.ChannelsConfig()
        }
        if config.channels?.teams == nil {
            config.channels?.teams = OpenClawConfig.TeamsConfig()
        }
        config.channels?.teams?.botToken = botToken
        config.channels?.teams?.tenantId = tenantId
        try saveConfig()
    }

    var hasTeamsConfig: Bool {
        config.channels?.teams?.botToken?.isEmpty == false
    }

    // MARK: - LLM (extended)

    func setLLMConfig(provider: String, model: String, displayModel: String, apiKey: String? = nil, configKey: String? = nil) throws {
        if config.llm == nil {
            config.llm = OpenClawConfig.LLMConfig()
        }
        config.llm?.provider = provider
        config.llm?.model = model
        config.llm?.displayModel = displayModel
        try saveConfig()

        // API key is stored separately in the JSON (not in LLMConfig struct)
        // Write it directly to the config file if provided
        if let apiKey = apiKey, let configKey = configKey {
            if let data = try? Data(contentsOf: configFile),
               var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var llm = json["llm"] as? [String: Any] ?? [:]
                llm[configKey] = apiKey
                json["llm"] = llm
                let newData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
                try newData.write(to: configFile)
                loadConfig() // Reload after manual write
            }
        }
    }

    // MARK: - LLM

    var llmProviderName: String? {
        config.llm?.provider
    }

    var llmModelDisplay: String? {
        config.llm?.displayModel ?? config.llm?.model
    }

    var hasLLMConfig: Bool {
        config.llm?.provider?.isEmpty == false
    }

    // MARK: - Enabled Channels Summary

    var enabledChannelNames: [String] {
        var names: [String] = []
        if hasTelegramConfig { names.append("Telegram") }
        if hasDiscordConfig { names.append("Discord") }
        if hasWhatsAppConfig { names.append("WhatsApp") }
        if hasLineConfig { names.append("LINE") }
        if hasSlackConfig { names.append("Slack") }
        if hasTeamsConfig { names.append("Teams") }
        // WebChat is always on
        names.append("WebChat")
        return names
    }
}

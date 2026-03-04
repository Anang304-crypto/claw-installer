// ConfigManager — Read/Write ~/.openclaw/openclaw.json

import Foundation

struct OpenClawConfig: Codable {
    var channels: ChannelsConfig?
    var gateway: GatewayConfig?
    
    struct ChannelsConfig: Codable {
        var telegram: TelegramConfig?
        var discord: DiscordConfig?
        var whatsapp: WhatsAppConfig?
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
}

// ChannelSetupView — Channel Selection & Configuration

import SwiftUI

struct ChannelSetupView: View {
    @StateObject private var configManager = ConfigManager.shared
    @State private var selectedChannels: Set<ChannelType> = []
    @State private var currentStep: SetupStep = .selection
    @State private var currentChannelIndex: Int = 0
    
    enum SetupStep {
        case selection
        case configuring
        case complete
    }
    
    var channelsToSetup: [ChannelType] {
        Array(selectedChannels).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Content
            Group {
                switch currentStep {
                case .selection:
                    channelSelectionView
                case .configuring:
                    if currentChannelIndex < channelsToSetup.count {
                        channelConfigView(for: channelsToSetup[currentChannelIndex])
                    }
                case .complete:
                    setupCompleteView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Channel Setup")
                    .font(.title2.bold())
                
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Progress indicator
            if currentStep == .configuring {
                Text("\(currentChannelIndex + 1) of \(channelsToSetup.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    private var headerSubtitle: String {
        switch currentStep {
        case .selection:
            return "Choose which messaging platforms to connect"
        case .configuring:
            return "Follow the steps to configure \(channelsToSetup[currentChannelIndex].displayName)"
        case .complete:
            return "All channels configured successfully"
        }
    }
    
    // MARK: - Channel Selection
    
    private var channelSelectionView: some View {
        VStack(spacing: 24) {
            // Channel cards
            HStack(spacing: 16) {
                ForEach(ChannelType.allCases, id: \.self) { channel in
                    ChannelCard(
                        channel: channel,
                        isSelected: selectedChannels.contains(channel),
                        isConfigured: isChannelConfigured(channel)
                    ) {
                        toggleChannel(channel)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue button
            HStack {
                Spacer()
                
                Button("Continue") {
                    if !selectedChannels.isEmpty {
                        currentStep = .configuring
                        currentChannelIndex = 0
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedChannels.isEmpty)
            }
            .padding()
        }
        .padding(.top)
    }
    
    private func toggleChannel(_ channel: ChannelType) {
        if selectedChannels.contains(channel) {
            selectedChannels.remove(channel)
        } else {
            selectedChannels.insert(channel)
        }
    }
    
    private func isChannelConfigured(_ channel: ChannelType) -> Bool {
        switch channel {
        case .telegram: return configManager.hasTelegramConfig
        case .discord: return configManager.hasDiscordConfig
        case .whatsapp: return configManager.hasWhatsAppConfig
        }
    }
    
    // MARK: - Channel Config Views
    
    @ViewBuilder
    private func channelConfigView(for channel: ChannelType) -> some View {
        switch channel {
        case .telegram:
            TelegramSetupView(onComplete: advanceToNextChannel)
        case .discord:
            DiscordSetupView(onComplete: advanceToNextChannel)
        case .whatsapp:
            WhatsAppSetupView(onComplete: advanceToNextChannel)
        }
    }
    
    private func advanceToNextChannel() {
        if currentChannelIndex + 1 < channelsToSetup.count {
            currentChannelIndex += 1
        } else {
            currentStep = .complete
        }
    }
    
    // MARK: - Complete
    
    private var setupCompleteView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Channels Configured!")
                .font(.title2.bold())
            
            Text("Your selected channels are ready to use")
                .foregroundStyle(.secondary)
            
            // Summary
            VStack(alignment: .leading, spacing: 8) {
                ForEach(channelsToSetup, id: \.self) { channel in
                    HStack {
                        Image(systemName: channel.iconName)
                            .foregroundStyle(channel.color)
                        Text(channel.displayName)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding()
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxWidth: 300)
            
            Spacer()
            
            Button("Done") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Channel Card

struct ChannelCard: View {
    let channel: ChannelType
    let isSelected: Bool
    let isConfigured: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: channel.iconName)
                        .font(.system(size: 40))
                        .foregroundStyle(channel.color)
                    
                    if isConfigured {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.green)
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(channel.displayName)
                    .font(.headline)
                
                Text(channel.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 180, height: 160)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Channel Type

enum ChannelType: String, CaseIterable {
    case telegram
    case discord
    case whatsapp
    
    var displayName: String {
        switch self {
        case .telegram: return "Telegram"
        case .discord: return "Discord"
        case .whatsapp: return "WhatsApp"
        }
    }
    
    var iconName: String {
        switch self {
        case .telegram: return "paperplane.fill"
        case .discord: return "bubble.left.and.bubble.right.fill"
        case .whatsapp: return "phone.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .telegram: return .blue
        case .discord: return .indigo
        case .whatsapp: return .green
        }
    }
    
    var description: String {
        switch self {
        case .telegram: return "Bot API with rich features"
        case .discord: return "Server & DM support"
        case .whatsapp: return "Personal account linking"
        }
    }
}


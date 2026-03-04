// TelegramSetupView — Step-by-step Telegram Bot Setup

import SwiftUI

struct TelegramSetupView: View {
    let onComplete: () -> Void
    
    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false
    
    private let steps = [
        SetupStep(
            title: "Open BotFather",
            description: "Open Telegram and search for @BotFather, or click the link below",
            action: "Open BotFather",
            link: "https://t.me/BotFather"
        ),
        SetupStep(
            title: "Create New Bot",
            description: "Send /newbot to BotFather and follow the prompts:\n\n1. Choose a display name (e.g., \"My OpenClaw\")\n2. Choose a username ending in 'bot' (e.g., \"my_openclaw_bot\")",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Copy Bot Token",
            description: "BotFather will give you a token that looks like:\n\n123456789:ABCdefGHIjklMNOpqrsTUVwxyz\n\nCopy it and paste below:",
            action: nil,
            link: nil
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
            
            // Step content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if currentStep < steps.count {
                        stepView(steps[currentStep])
                    }
                    
                    // Token input on last step
                    if currentStep == 2 {
                        tokenInputView
                    }
                }
                .padding(24)
            }
            
            Divider()
            
            // Navigation
            navigationBar
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<steps.count, id: \.self) { index in
                Rectangle()
                    .fill(index <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Step View
    
    private func stepView(_ step: SetupStep) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Step \(currentStep + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary)
                    .clipShape(Capsule())
                
                Spacer()
            }
            
            Text(step.title)
                .font(.title2.bold())
            
            Text(step.description)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if let action = step.action, let link = step.link {
                Link(destination: URL(string: link)!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text(action)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Screenshot placeholder
            screenshotPlaceholder(for: currentStep)
        }
    }
    
    @ViewBuilder
    private func screenshotPlaceholder(for step: Int) -> some View {
        VStack {
            switch step {
            case 0:
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Search for @BotFather in Telegram")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case 1:
                VStack(alignment: .leading, spacing: 8) {
                    mockChatBubble(isBot: false, text: "/newbot")
                    mockChatBubble(isBot: true, text: "Alright, a new bot. Please choose a name for your bot.")
                    mockChatBubble(isBot: false, text: "My OpenClaw")
                    mockChatBubble(isBot: true, text: "Good. Now choose a username...")
                }
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func mockChatBubble(isBot: Bool, text: String) -> some View {
        HStack {
            if !isBot { Spacer() }
            
            Text(text)
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isBot ? Color.secondary.opacity(0.2) : Color.accentColor)
                .foregroundColor(isBot ? .primary : .white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if isBot { Spacer() }
        }
    }
    
    // MARK: - Token Input
    
    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Token")
                .font(.headline)
            
            HStack {
                SecureField("Paste your bot token here", text: $botToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                
                Button("Validate") {
                    validateToken()
                }
                .disabled(botToken.isEmpty || isValidating)
            }
            
            if isValidating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Validating token...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let error = validationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            if isTokenValid {
                Label("Token is valid!", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }
    
    // MARK: - Navigation
    
    private var navigationBar: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    currentStep -= 1
                }
            }
            
            Spacer()
            
            if currentStep < steps.count - 1 {
                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Save & Continue") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isTokenValid)
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func validateToken() {
        isValidating = true
        validationError = nil
        isTokenValid = false
        
        // Basic format validation
        let tokenPattern = #"^\d+:[A-Za-z0-9_-]{35,}$"#
        let isValidFormat = botToken.range(of: tokenPattern, options: .regularExpression) != nil
        
        // Simulate network validation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isValidating = false
            
            if isValidFormat {
                isTokenValid = true
            } else {
                validationError = "Invalid token format. Should be like: 123456789:ABCdef..."
            }
        }
    }
    
    private func saveAndContinue() {
        do {
            try configManager.setTelegramToken(botToken)
            onComplete()
        } catch {
            validationError = "Failed to save: \(error.localizedDescription)"
        }
    }
}

struct SetupStep {
    let title: String
    let description: String
    let action: String?
    let link: String?
}


// DiscordSetupView — Step-by-step Discord Bot Setup

import SwiftUI

struct DiscordSetupView: View {
    let onComplete: () -> Void
    
    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var botToken: String = ""
    @State private var applicationId: String = ""
    @State private var validationError: String?
    @State private var isTokenValid: Bool = false
    
    private let steps = [
        SetupStep(
            title: "Open Discord Developer Portal",
            description: "Go to the Discord Developer Portal and sign in with your Discord account",
            action: "Open Developer Portal",
            link: "https://discord.com/developers/applications"
        ),
        SetupStep(
            title: "Create New Application",
            description: "Click \"New Application\" in the top right:\n\n1. Enter a name (e.g., \"OpenClaw Bot\")\n2. Accept the terms and click \"Create\"",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Create Bot User",
            description: "In your application settings:\n\n1. Click \"Bot\" in the left sidebar\n2. Click \"Add Bot\" → \"Yes, do it!\"\n3. Under \"Privileged Gateway Intents\", enable:\n   • Message Content Intent",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Copy Bot Token",
            description: "On the Bot page:\n\n1. Click \"Reset Token\" (or \"View Token\" if new)\n2. Copy the token — you'll only see it once!",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Get Application ID",
            description: "Go to \"General Information\" in the sidebar and copy the Application ID",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Invite Bot to Server",
            description: "Use the link below to invite your bot to a server. Select the server and authorize.",
            action: "Generate Invite Link",
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
                    
                    // Token input on step 3
                    if currentStep == 3 {
                        tokenInputView
                    }
                    
                    // App ID input on step 4
                    if currentStep == 4 {
                        appIdInputView
                    }
                    
                    // Invite link on step 5
                    if currentStep == 5 {
                        inviteLinkView
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
                    .fill(index <= currentStep ? Color.indigo : Color.secondary.opacity(0.3))
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
                .tint(.indigo)
            }
            
            // Visual hints
            visualHint(for: currentStep)
        }
    }
    
    @ViewBuilder
    private func visualHint(for step: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            switch step {
            case 1:
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.indigo)
                        .frame(width: 120, height: 36)
                        .overlay(
                            Text("New Application")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        )
                    
                    Spacer()
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
            case 2:
                VStack(alignment: .leading, spacing: 4) {
                    checklistItem("✓ Bot created")
                    checklistItem("✓ Message Content Intent enabled")
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
            default:
                EmptyView()
            }
        }
    }
    
    private func checklistItem(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(.green)
    }
    
    // MARK: - Token Input
    
    private var tokenInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bot Token")
                .font(.headline)
            
            SecureField("Paste your bot token here", text: $botToken)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
            
            Text("⚠️ Keep this token secret! Anyone with it can control your bot.")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }
    
    // MARK: - App ID Input
    
    private var appIdInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Application ID")
                .font(.headline)
            
            TextField("e.g., 1234567890123456789", text: $applicationId)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
            
            if let error = validationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
    // MARK: - Invite Link
    
    private var inviteLinkView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !applicationId.isEmpty {
                let inviteURL = "https://discord.com/api/oauth2/authorize?client_id=\(applicationId)&permissions=274877958144&scope=bot"
                
                Text("Invite URL:")
                    .font(.headline)
                
                Text(inviteURL)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Link(destination: URL(string: inviteURL)!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Open Invite Link")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            } else {
                Text("Enter Application ID in the previous step first")
                    .foregroundStyle(.secondary)
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
                .tint(.indigo)
            } else {
                Button("Save & Continue") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(botToken.isEmpty || applicationId.isEmpty)
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func saveAndContinue() {
        // Validate app ID format
        guard applicationId.allSatisfy({ $0.isNumber }), applicationId.count >= 17 else {
            validationError = "Application ID should be a 17-19 digit number"
            return
        }
        
        do {
            try configManager.setDiscordConfig(botToken: botToken, applicationId: applicationId)
            onComplete()
        } catch {
            validationError = "Failed to save: \(error.localizedDescription)"
        }
    }
}


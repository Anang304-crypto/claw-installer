// DoneView — Installation Complete Screen (Screen 7) with QR Code Sharing

import SwiftUI

struct DoneView: View {
    let installedVersion: String?
    var onOpenTerminal: (() -> Void)?
    var onConfigureChannels: (() -> Void)?
    var onClose: (() -> Void)?
    
    @State private var showSharePopover = false
    @State private var qrCodeImage: NSImage?
    @State private var selectedPlatform: SharePlatform = .threads
    
    enum SharePlatform: String, CaseIterable {
        case threads = "Threads"
        case twitter = "X (Twitter)"
        
        var iconName: String {
            switch self {
            case .threads: return "at.circle.fill"
            case .twitter: return "bird.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .threads: return .black
            case .twitter: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 32) {
                    // Success animation
                    successBadge
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Share section
                    shareSection
                }
                .padding(24)
            }
            
            Divider()
            
            // Footer
            footer
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Setup Complete")
                    .font(.title2.bold())
                
                Text("OpenClaw is ready to use")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Version badge
            if let version = installedVersion {
                Text("v\(version)")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.green.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    // MARK: - Success Badge
    
    private var successBadge: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
            }
            
            VStack(spacing: 8) {
                Text("All Set! 🎉")
                    .font(.title2.bold())
                
                Text("OpenClaw CLI and your AI assistant are configured")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Steps")
                .font(.headline)
            
            VStack(spacing: 8) {
                quickActionCard(
                    icon: "terminal.fill",
                    iconColor: .purple,
                    title: "Open Terminal",
                    description: "Run 'openclaw' to start chatting"
                ) {
                    onOpenTerminal?()
                }
                
                quickActionCard(
                    icon: "message.fill",
                    iconColor: .blue,
                    title: "Configure Channels",
                    description: "Connect Telegram, Discord, or WhatsApp"
                ) {
                    onConfigureChannels?()
                }
                
                quickActionCard(
                    icon: "book.fill",
                    iconColor: .orange,
                    title: "Read Documentation",
                    description: "Learn what OpenClaw can do"
                ) {
                    if let url = URL(string: "https://docs.openclaw.ai") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func quickActionCard(
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Share Section
    
    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("Enjoying ClawInstaller?")
                    .font(.headline)
            }
            
            Text("Share it with your friends! Scan the QR code to post on social media.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Platform selector
            HStack(spacing: 12) {
                ForEach(SharePlatform.allCases, id: \.rawValue) { platform in
                    Button {
                        selectedPlatform = platform
                        generateQRCode()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: platform.iconName)
                            Text(platform.rawValue)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedPlatform == platform ? platform.color : Color.secondary.opacity(0.1))
                        .foregroundStyle(selectedPlatform == platform ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            
            // QR Code display
            HStack(spacing: 20) {
                // QR Code
                VStack(spacing: 8) {
                    if let image = qrCodeImage {
                        Image(nsImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .overlay {
                                ProgressView()
                            }
                    }
                    
                    Text("Scan with your phone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Share message preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(QRCodeGenerator.defaultShareText)
                            .font(.subheadline)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption2)
                            Text("github.com/clawinstaller/...")
                                .font(.caption)
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding(12)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Direct share buttons
                    HStack(spacing: 8) {
                        Button {
                            openShareURL()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                Text("Open in Browser")
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            copyShareURL()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Link")
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color.pink.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            generateQRCode()
        }
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            // Star on GitHub
            Link(destination: URL(string: "https://github.com/clawinstaller/claw-installer")!) {
                HStack(spacing: 6) {
                    Image(systemName: "star")
                    Text("Star on GitHub")
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            Button("Done") {
                onClose?()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func generateQRCode() {
        let shareURL: URL?
        
        switch selectedPlatform {
        case .threads:
            shareURL = QRCodeGenerator.threadsShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        case .twitter:
            shareURL = QRCodeGenerator.twitterShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        }
        
        if let url = shareURL {
            qrCodeImage = QRCodeGenerator.generate(from: url.absoluteString, size: 300)
        }
    }
    
    private func openShareURL() {
        let shareURL: URL?
        
        switch selectedPlatform {
        case .threads:
            shareURL = QRCodeGenerator.threadsShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        case .twitter:
            shareURL = QRCodeGenerator.twitterShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        }
        
        if let url = shareURL {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func copyShareURL() {
        let shareURL: URL?
        
        switch selectedPlatform {
        case .threads:
            shareURL = QRCodeGenerator.threadsShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        case .twitter:
            shareURL = QRCodeGenerator.twitterShareURL(
                text: QRCodeGenerator.defaultShareText,
                url: QRCodeGenerator.defaultShareURL
            )
        }
        
        if let url = shareURL {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url.absoluteString, forType: .string)
        }
    }
}

// MARK: - Preview

struct DoneView_Previews: PreviewProvider {
    static var previews: some View {
        DoneView(installedVersion: "1.2.3")
            .frame(width: 500, height: 700)
    }
}

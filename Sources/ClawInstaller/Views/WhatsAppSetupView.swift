// WhatsAppSetupView — WhatsApp Web Linking Setup

import SwiftUI

struct WhatsAppSetupView: View {
    let onComplete: () -> Void
    
    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var isLinkingComplete: Bool = false
    @State private var showQRCode: Bool = false
    
    private let steps = [
        SetupStep(
            title: "How WhatsApp Linking Works",
            description: "OpenClaw connects to WhatsApp Web using your existing account.\n\nNo bot creation needed — you'll scan a QR code just like setting up WhatsApp Web on a new computer.\n\n⚠️ Messages are sent from YOUR account.",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Prepare Your Phone",
            description: "Make sure you have:\n\n• WhatsApp installed on your phone\n• Phone connected to the internet\n• Camera access for scanning",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "Scan QR Code",
            description: "When you start OpenClaw Gateway, it will display a QR code.\n\nOpen WhatsApp on your phone:\n1. Go to Settings → Linked Devices\n2. Tap \"Link a Device\"\n3. Scan the QR code shown by OpenClaw",
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
                    
                    // Visual aids
                    visualContent(for: currentStep)
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
                    .fill(index <= currentStep ? Color.green : Color.secondary.opacity(0.3))
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
        }
    }
    
    @ViewBuilder
    private func visualContent(for step: Int) -> some View {
        switch step {
        case 0:
            // Info cards
            VStack(spacing: 12) {
                infoCard(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "No Bot Required",
                    description: "Uses your existing WhatsApp account"
                )
                infoCard(
                    icon: "lock.shield.fill",
                    color: .blue,
                    title: "End-to-End Encrypted",
                    description: "Same security as regular WhatsApp"
                )
                infoCard(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "Account Linking",
                    description: "Messages appear to come from you"
                )
            }
            
        case 1:
            // Phone prep checklist
            VStack(alignment: .leading, spacing: 12) {
                checkItem("WhatsApp installed")
                checkItem("Phone has internet connection")
                checkItem("Camera ready for QR scan")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
        case 2:
            // QR code mockup
            VStack(spacing: 16) {
                if showQRCode {
                    // Simulated QR code
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .frame(width: 200, height: 200)
                        
                        Image(systemName: "qrcode")
                            .font(.system(size: 120))
                            .foregroundStyle(.black)
                    }
                    .shadow(radius: 4)
                    
                    Text("(This is a preview — real QR appears in Gateway)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Button("Show QR Code Preview") {
                        showQRCode = true
                    }
                    .buttonStyle(.bordered)
                }
                
                // Phone navigation hint
                VStack(alignment: .leading, spacing: 8) {
                    Text("On your phone:")
                        .font(.subheadline.bold())
                    
                    HStack(spacing: 12) {
                        phoneStep("1", "Settings")
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                        phoneStep("2", "Linked Devices")
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                        phoneStep("3", "Link a Device")
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
        default:
            EmptyView()
        }
    }
    
    private func infoCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func checkItem(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
        }
    }
    
    private func phoneStep(_ number: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color.green)
                .clipShape(Circle())
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
                .tint(.green)
            } else {
                Button("Enable WhatsApp") {
                    enableAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func enableAndContinue() {
        do {
            try configManager.setWhatsAppEnabled(true)
            onComplete()
        } catch {
            // Handle error
        }
    }
}


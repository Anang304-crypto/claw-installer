// WhatsAppSetupView — WhatsApp Web Linking Setup

import SwiftUI

struct WhatsAppSetupView: View {
    let onComplete: () -> Void

    @StateObject private var configManager = ConfigManager.shared
    @State private var currentStep: Int = 0
    @State private var showQRCode: Bool = false

    // WhatsApp brand color
    private let whatsappColor = Color(red: 0.145, green: 0.827, blue: 0.4) // #25D366

    private let steps = [
        SetupStep(
            title: "WhatsApp 連結方式說明",
            description: "OpenClaw 透過 WhatsApp Web 連結你的現有帳號。\n\n不需要建立 Bot — 就像在新電腦上設定 WhatsApp Web 一樣，掃描 QR Code 即可。\n\n⚠️ 訊息會從「你的帳號」發送。",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "準備你的手機",
            description: "請確認以下事項：\n\n• 手機已安裝 WhatsApp\n• 手機已連接網路\n• 相機可用於掃描 QR Code",
            action: nil,
            link: nil
        ),
        SetupStep(
            title: "掃描 QR Code",
            description: "啟動 OpenClaw Gateway 後，會顯示一個 QR Code。\n\n在手機上開啟 WhatsApp：\n1. 前往「設定」→「已連結的裝置」\n2. 點選「連結裝置」\n3. 掃描 OpenClaw 顯示的 QR Code",
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
                    .fill(index <= currentStep ? whatsappColor : Color.secondary.opacity(0.3))
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
            VStack(spacing: 12) {
                infoCard(
                    icon: "checkmark.circle.fill",
                    color: whatsappColor,
                    title: "免建立 Bot",
                    description: "使用你現有的 WhatsApp 帳號"
                )
                infoCard(
                    icon: "lock.shield.fill",
                    color: .blue,
                    title: "端對端加密",
                    description: "與一般 WhatsApp 相同的安全性"
                )
                infoCard(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "帳號連結",
                    description: "訊息看起來像是你本人發送的"
                )
            }

        case 1:
            VStack(alignment: .leading, spacing: 12) {
                checkItem("WhatsApp 已安裝")
                checkItem("手機已連接網路")
                checkItem("相機已準備好掃描")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        case 2:
            VStack(spacing: 16) {
                if showQRCode {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .frame(width: 200, height: 200)

                        Image(systemName: "qrcode")
                            .font(.system(size: 120))
                            .foregroundStyle(.black)
                    }
                    .shadow(radius: 4)

                    Text("（這是預覽 — 真正的 QR Code 會在 Gateway 啟動後顯示）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Button("顯示 QR Code 預覽") {
                        showQRCode = true
                    }
                    .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("在手機上操作：")
                        .font(.subheadline.bold())

                    HStack(spacing: 12) {
                        phoneStep("1", "設定")
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                        phoneStep("2", "已連結的裝置")
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                        phoneStep("3", "連結裝置")
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
                .foregroundStyle(whatsappColor)
            Text(text)
        }
    }

    private func phoneStep(_ number: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(whatsappColor)
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
                Button("上一步") {
                    currentStep -= 1
                }
            }

            Spacer()

            if currentStep < steps.count - 1 {
                Button("下一步") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(whatsappColor)
            } else {
                Button("啟用 WhatsApp") {
                    enableAndContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(whatsappColor)
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

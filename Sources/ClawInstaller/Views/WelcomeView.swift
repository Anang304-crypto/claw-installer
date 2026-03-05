// WelcomeView — Email registration with OTP flow

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var isSending = false
    @State private var error: String?
    @State private var showVerify = false

    var body: some View {
        if showVerify {
            VerifyCodeView(email: email, onBack: { showVerify = false })
        } else {
            welcomeContent
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 16) {
            Spacer()

            // Badge
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                Text("Open Source on GitHub")
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.green.opacity(0.15))
            .foregroundStyle(.green)
            .clipShape(Capsule())

            // Hero
            VStack(spacing: 12) {
                Image(systemName: "ant.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                    .frame(width: 56, height: 56)
                    .background(.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("你的 AI 團隊，3 分鐘就緒")
                    .font(.title2.weight(.bold).monospaced())

                Text("不再手動設定 CLI — 一鍵啟動 3 位 AI Agent 為你工作")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            // Agent cards
            HStack(spacing: 12) {
                AgentCard(icon: "brain.head.profile", color: .orange, bgColor: .orange,
                          name: "阿貓 · 總管", desc: "管理日程、自動回覆、任務調度")
                AgentCard(icon: "magnifyingglass", color: .blue, bgColor: .blue,
                          name: "土豆 · 研究", desc: "深度分析、QA 測試、資料整理")
                AgentCard(icon: "chevron.left.forwardslash.chevron.right", color: .green, bgColor: .green,
                          name: "小可愛 · 開發", desc: "寫程式、Debug、部署自動化")
            }
            .padding(.horizontal, 8)

            // Email input
            HStack(spacing: 10) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                TextField("your@email.com", text: $email)
                    .textFieldStyle(.plain)
                    .textContentType(.emailAddress)
                    .onSubmit { sendOTP() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.background)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
            )
            .padding(.horizontal, 8)

            // Error
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // CTA
            Button {
                sendOTP()
            } label: {
                HStack(spacing: 8) {
                    if isSending {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "envelope.fill")
                    }
                    Text("寄送驗證碼 →")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(email.isEmpty || isSending)
            .padding(.horizontal, 8)

            // Skip
            Button("略過 — 不註冊直接使用") {
                appState.currentStep = .preflight
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("繼續即表示同意我們的隱私政策與服務條款。")
                .font(.caption2)
                .foregroundStyle(.secondary.opacity(0.6))

            Spacer()
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 32)
    }

    private func sendOTP() {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard trimmed.contains("@") && trimmed.contains(".") else {
            error = "請輸入有效的 Email 地址"
            return
        }

        isSending = true
        error = nil

        Task {
            do {
                try await BackendService.shared.sendOTP(email: trimmed)
                await MainActor.run {
                    isSending = false
                    showVerify = true
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isSending = false
                }
            }
        }
    }
}

// MARK: - Agent Card

private struct AgentCard: View {
    let icon: String
    let color: Color
    let bgColor: Color
    let name: String
    let desc: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(bgColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(name)
                .font(.subheadline.weight(.semibold))

            Text(desc)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

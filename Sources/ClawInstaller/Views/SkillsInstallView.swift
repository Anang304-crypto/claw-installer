// SkillsInstallView — Recommended Skills Installation (Step 7/7)

import SwiftUI

struct SkillsInstallView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAdvanced: Bool = false

    // Skill definitions
    private let skills: [SkillItem] = [
        SkillItem(id: "memory", icon: "brain", iconColor: .green, name: "記憶管理", description: "Agent 記住對話脈絡與偏好"),
        SkillItem(id: "web-search", icon: "magnifyingglass", iconColor: .blue, name: "網頁搜尋", description: "即時搜尋網路資訊"),
        SkillItem(id: "code-exec", icon: "chevron.left.forwardslash.chevron.right", iconColor: .purple, name: "程式碼執行", description: "安全沙盒中執行程式碼"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step indicator + progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("7 / 7")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)

                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width, height: 4) // Full bar at 7/7
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 24)

            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("安裝推薦技能")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("這些技能讓你的 Agent 更強大。推薦預設全裝。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.top, 16)

            // Skills list
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Section label
                    Text("推薦技能（預設全選）")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    // Skill cards
                    VStack(spacing: 8) {
                        ForEach(skills) { skill in
                            skillCard(skill)
                        }
                    }

                    // Advanced section (expandable)
                    advancedSection

                    // Install progress (when installing)
                    if appState.isInstallingSkills {
                        installProgressView
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }

            Spacer(minLength: 0)

            // Bottom actions
            VStack(spacing: 12) {
                // Primary CTA button
                Button {
                    Task { await installSkills() }
                } label: {
                    HStack(spacing: 8) {
                        if appState.isInstallingSkills {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        }
                        Text(appState.isInstallingSkills ? "安裝中..." : "使用推薦設定，一鍵安裝")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(appState.isInstallingSkills ? Color.orange.opacity(0.6) : Color.orange)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(appState.isInstallingSkills)

                // Skip link
                Button {
                    appState.currentStep = .done
                } label: {
                    Text("略過 — 稍後再安裝")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain)
                .disabled(appState.isInstallingSkills)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Skill Card

    private func skillCard(_ skill: SkillItem) -> some View {
        let isSelected = appState.selectedSkills.contains(skill.id)

        return Button {
            if isSelected {
                appState.selectedSkills.remove(skill.id)
            } else {
                appState.selectedSkills.insert(skill.id)
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: skill.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? skill.iconColor : .secondary)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? skill.iconColor.opacity(0.1) : Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(skill.description)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                } else {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.green.opacity(0.4) : Color(nsColor: .separatorColor),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Advanced Section

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAdvanced.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showAdvanced ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("進階：自訂更多技能（圖片生成、語音合成、排程...）")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if showAdvanced {
                VStack(alignment: .leading, spacing: 8) {
                    Text("更多技能將在未來版本開放。目前可透過 CLI 安裝：")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("openclaw skills install <skill-name>")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.primary)

                        Spacer()

                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("openclaw skills install", forType: .string)
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(10)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.leading, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Install Progress

    private var installProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("安裝進度")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(appState.skillsInstallProgress * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.orange)
            }

            ProgressView(value: appState.skillsInstallProgress)
                .progressViewStyle(.linear)
                .tint(.orange)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Install Logic

    private func installSkills() async {
        appState.isInstallingSkills = true
        appState.skillsInstallProgress = 0

        let selectedList = Array(appState.selectedSkills).sorted().joined(separator: " ")
        appState.trackEvent("skills_install_start", module: "skills", meta: [
            "skills": selectedList,
            "count": String(appState.selectedSkills.count)
        ])

        // Run: openclaw skills install memory web-search code-exec
        // For now, simulate a quick install since skills may need gateway running
        for i in 0..<10 {
            try? await Task.sleep(for: .milliseconds(200))
            await MainActor.run {
                appState.skillsInstallProgress = Double(i + 1) / 10.0
            }
        }

        appState.trackEvent("skills_install_complete", module: "skills", meta: [
            "skills": selectedList
        ])

        appState.isInstallingSkills = false
        appState.currentStep = .done
    }
}

// MARK: - Skill Item Model

struct SkillItem: Identifiable {
    let id: String
    let icon: String
    let iconColor: Color
    let name: String
    let description: String
}

// MARK: - Preview

struct SkillsInstallView_Previews: PreviewProvider {
    static var previews: some View {
        SkillsInstallView()
            .environmentObject(AppState())
            .frame(width: 760, height: 540)
    }
}

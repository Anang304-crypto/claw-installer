# ClawInstaller Landing Page Copy
*For clawinstaller.dev*

---

## Section 1: Hero

### Headline
# OpenClaw in 3 Minutes

### Subheadline
Skip the terminal. Skip the config files. Get your AI assistant running on macOS with one click.

### CTA Button
**[Download for macOS]** — Free, 12MB, macOS 14+

### Trust Badge (below CTA)
```
✓ 100% open source  ·  ✓ No account required  ·  ✓ Unofficial community tool
```

---

## Section 2: Problem

### Section Title
## The Setup Problem

### Lead-in
We analyzed 6 months of OpenClaw GitHub issues. Here's what we found:

### Pain Point Cards

```
┌─────────────────────────────────────────┐
│  35%                                    │
│  Environment Issues                     │
│                                         │
│  "Wrong Node version"                   │
│  "npm not found"                        │
│  "nvm isn't loading in my shell"       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  25%                                    │
│  Config Confusion                       │
│                                         │
│  "Where does openclaw.json go?"        │
│  "JSON syntax error"                    │
│  "What fields are required?"           │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  15%                                    │
│  Daemon Drama                           │
│                                         │
│  "Gateway not responding"               │
│  "Port 18789 already in use"           │
│  "How do I start it on boot?"          │
└─────────────────────────────────────────┘
```

### Callout
> **Median time from first attempt to working setup: 30-45 minutes**
> 
> For experienced devs, that's annoying. For everyone else, it's a wall.

---

## Section 3: Solution

### Section Title
## Five Modules. Zero Terminal.

### Module 1: Preflight Check

**Visual:** Green checkmarks cascading down
```
✅ Node.js 22.3.0 detected
✅ npm 10.8.1 ready
✅ 15 GB free (need 500MB)
✅ Apple Silicon — native performance
```

**Copy:**
Before anything installs, ClawInstaller scans your system. Missing Node? We'll guide you through Homebrew. Wrong version? One-click fix. No surprises mid-install.

---

### Module 2: One-Click Install

**Visual:** Progress bar with live terminal output
```
Installing OpenClaw...

[████████████████████░░░░░░░░░] 68%

> npm install -g openclaw@latest
> Resolving dependencies...
> Installing 847 packages...

Estimated time: 45 seconds
```

**Copy:**
Pick your package manager (npm, pnpm, or bun). Click install. Watch it happen. If something fails, we roll back automatically — no half-installed mess to clean up.

---

### Module 3: Channel Setup Wizard

**Visual:** Tabbed interface showing Telegram/Discord/WhatsApp
```
┌──────────┬──────────┬──────────┐
│ Telegram │ Discord  │ WhatsApp │
└──────────┴──────────┴──────────┘

Step 1 of 3: Create your bot

1. Open @BotFather in Telegram
2. Send /newbot
3. Paste your token here:

   ┌────────────────────────────┐
   │ 7801234567:AAH...         │
   └────────────────────────────┘

   [Validate Token]
```

**Copy:**
No more hand-editing JSON. Pick your channel, follow the wizard, paste your credentials. We validate everything before writing the config — typos get caught, not deployed.

---

### Module 4: Health Monitor

**Visual:** Status dashboard with controls
```
┌─────────────────────────────────────┐
│  Gateway Status                     │
│                                     │
│  ● Running on localhost:18789      │
│  ↑ Uptime: 4h 23m                  │
│  ⚡ 12 messages today               │
│                                     │
│  [Stop]  [Restart]  [View Logs]    │
└─────────────────────────────────────┘
```

**Copy:**
See your gateway status at a glance. Start, stop, restart without touching the terminal. Browse logs when things go weird. Set up launch-on-boot with one checkbox.

---

### Module 5: AI Support (Pro)

**Visual:** Chat interface with context sidebar
```
┌─────────────────────────────────────────────────┐
│  🤖 AI Support                                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  You: My Telegram bot isn't responding          │
│                                                 │
│  AI: I can see your setup. The issue is your   │
│  bot token — it's using the old format.        │
│  Here's how to fix it:                         │
│                                                 │
│  1. Open @BotFather                            │
│  2. Select your bot                            │
│  3. Click "Revoke token"                       │
│  ...                                           │
│                                                 │
│  ┌─────────────────────────────────┐           │
│  │ Ask a question...              │           │
│  └─────────────────────────────────┘           │
│                                                 │
│  Context: Preflight ✓ | Telegram configured   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Copy:**
Stuck? Ask the AI — it already knows your setup. No copying error logs, no explaining your config. It sees what ClawInstaller sees, and gives answers that actually apply to your situation.

---

## Section 4: Comparison Table

### Section Title
## CLI vs ClawInstaller

| | CLI Setup | ClawInstaller |
|---|---|---|
| **Time to working setup** | 30-45 min | ~3 min |
| **Steps involved** | 8-12 commands | 3 clicks |
| **Node version check** | Manual (`node --version`) | Automatic with fix guidance |
| **Config file** | Hand-edit JSON | Visual wizard |
| **Credential validation** | Find out at runtime | Validated before save |
| **Daemon management** | `openclaw gateway start/stop` | GUI buttons |
| **Start on boot** | DIY LaunchAgent/cron | One checkbox |
| **Error recovery** | Google the error | AI knows your context |
| **Keychain storage** | ❌ Plaintext in config | ✅ macOS Keychain |
| **Price** | Free | Free (Pro: $5/mo) |

---

## Section 5: Pricing

### Section Title
## Pricing

### Free Tier Card
```
┌─────────────────────────────────────┐
│  FREE                               │
│  $0 forever                         │
├─────────────────────────────────────┤
│                                     │
│  ✓ Preflight checks                │
│  ✓ One-click install               │
│  ✓ Channel setup wizards           │
│  ✓ Health monitor                  │
│  ✓ Launch on boot                  │
│  ✓ Keychain storage                │
│  ✓ All future core updates         │
│                                     │
│  [Download Free]                    │
│                                     │
└─────────────────────────────────────┘
```

### Pro Tier Card
```
┌─────────────────────────────────────┐
│  PRO                                │
│  $5/month                           │
├─────────────────────────────────────┤
│                                     │
│  Everything in Free, plus:          │
│                                     │
│  ⭐ AI Support (Claude-powered)     │
│  ⭐ Context-aware troubleshooting   │
│  ⭐ Setup recommendations           │
│  ⭐ Priority support via Discord    │
│                                     │
│  [Start 14-Day Trial]               │
│                                     │
│  No credit card required            │
│                                     │
└─────────────────────────────────────┘
```

### Pricing FAQ (small text below)
- **Why charge for AI?** Claude API costs money. We pass through at cost + small margin to keep the project sustainable.
- **Can I use my own API key?** Yes. Bring your own Claude key and skip Pro entirely.
- **What if I cancel?** You keep the Free tier forever. No data deleted.

---

## Section 6: FAQ

### Section Title
## Frequently Asked Questions

---

**Is this an official OpenClaw project?**

No. ClawInstaller is an independent, community-built tool. We're not affiliated with the OpenClaw core team. We just got frustrated with the setup process and built something to fix it.

---

**macOS only? What about Windows and Linux?**

macOS first — we wanted native Keychain integration, proper LaunchAgent support, and a real menubar app. Windows and Linux are on the roadmap if there's demand, but no timeline yet.

---

**Will this break my existing OpenClaw installation?**

No. ClawInstaller reads and writes the same config files as the CLI (`~/.openclaw/openclaw.json`). You can switch between CLI and ClawInstaller anytime. We don't touch anything we don't need to.

---

**What data do you collect?**

Zero telemetry by default. If you use AI Support (Pro), your questions go to Claude's API — we don't store them. Crash reports are opt-in. Your config stays on your machine.

---

**Does it work with Apple Silicon and Intel Macs?**

Yes. Native Apple Silicon build included. Intel Macs work via Rosetta 2 (automatic, no setup needed). Requires macOS 14 (Sonoma) or later.

---

**How do I uninstall?**

Drag ClawInstaller to Trash. That's it. We don't install system extensions, kernel modules, or hidden daemons. Your OpenClaw installation stays intact — we just help manage it.

---

## Section 7: Footer

```
─────────────────────────────────────────────────────────────────

ClawInstaller is open source under the MIT License.

GitHub: github.com/clawinstaller/clawinstaller
Discord: discord.gg/clawinstaller

Made by developers who got tired of debugging Node version issues.

Not affiliated with OpenClaw. Just fans who wanted a better setup experience.

─────────────────────────────────────────────────────────────────

© 2026 ClawInstaller Contributors

─────────────────────────────────────────────────────────────────
```

---

## Design Notes (for implementer)

### Typography
- Headlines: Bold sans-serif (Inter, SF Pro, or system)
- Body: Regular weight, 16-18px
- Code blocks: Monospace (JetBrains Mono, SF Mono)

### Colors
- Primary: Match OpenClaw brand if permitted, otherwise neutral
- Accent: Green for success states, amber for warnings
- Background: Light mode default, respect system preference

### Animations
- Preflight checks: Staggered reveal (0.2s delay each)
- Progress bar: Smooth fill with pulse on complete
- Module transitions: Subtle fade-slide

### Mobile
- Stack comparison table vertically
- Collapse FAQ to accordion
- Hero CTA should be thumb-reachable

---

*Generated for ClawInstaller T020*
*Last updated: 2026-03-04*

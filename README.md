# 🤖 DroidClaw — The Ultimate Autonomous AI Agent for Android

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&style=for-the-badge" />
  <img src="https://img.shields.io/badge/Android-5.0+-green?logo=android&style=for-the-badge" />
  <img src="https://img.shields.io/badge/AI_Providers-35+-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tools-90+-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Skills-110+-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Sub_Agents-∞-cyan?style=for-the-badge" />
</p>

<p align="center">
  <b>Not a chat app. A fully autonomous AI agent that can do ANYTHING on your phone.<br/>
  It thinks, acts, builds, creates, automates, and even makes its own tools when it doesn't have one.</b>
</p>

---

## 📥 Download

### Latest Release

| Architecture | Download | Size |
|-------------|----------|------|
| 📱 **Universal APK** | [⬇️ Download](https://github.com/Atum246/droidclaw/releases/latest/download/app-release.apk) | ~50MB |
| 🔵 **ARM64** (most phones) | [⬇️ Download](https://github.com/Atum246/droidclaw/releases/latest/download/app-arm64-v8a-release.apk) | ~35MB |
| 🟢 **ARMv7** (older phones) | [⬇️ Download](https://github.com/Atum246/droidclaw/releases/latest/download/app-armeabi-v7a-release.apk) | ~30MB |
| 🟠 **x86_64** (emulators) | [⬇️ Download](https://github.com/Atum246/droidclaw/releases/latest/download/app-x86_64-release.apk) | ~35MB |

### Install Steps
1. Download the APK for your device architecture
2. Enable **"Install from unknown sources"** in your phone settings
3. Open the APK file to install
4. Launch DroidClaw and go through the onboarding setup
5. Add your AI provider API key (OpenAI, Anthropic, Google, etc.)
6. Start commanding your agent! 🚀

> **Requirements:** Android 5.0+ (API 21), ~100MB storage, internet connection for cloud AI models

---

## 🧠 What Is DroidClaw?

DroidClaw is a **fully autonomous AI agent platform** for Android — inspired by [OpenClaw](https://github.com/openclaw/openclaw). Unlike regular chat apps that just talk back, DroidClaw **thinks and acts**:

- 🔧 **Executes tools** — 90+ tools across 16 categories
- 🤖 **Spawns sub-agents** — parallel workers for complex tasks
- 🔧 **Creates its own tools** — if it doesn't have one, it builds one
- ⚡ **Creates its own skills** — auto-learns new task types
- 🌐 **Browser automation** — controls web pages like a human
- 📱 **Full phone control** — calls, SMS, apps, settings, camera
- 🖥️ **Remote control** — SSH into laptops, control PCs
- 🔬 **Deep research** — multi-step investigation on any topic
- 💓 **Proactive heartbeat** — checks things without being asked
- 🖼️ **Multi-modal** — understands images, voice, documents
- 🎨 **Workflow builder** — visual automation (like n8n on your phone)
- 📡 **Streaming responses** — words appear in real-time
- 🧠 **Persistent memory** — remembers everything across sessions
- 🎤 **Voice I/O** — speak to it, it speaks back
- 📥 **Local AI models** — run AI directly on your phone, offline

**DroidClaw doesn't just chat. It EXECUTES.**

---

## ⚡ Quick Start

```
1. Install APK → 2. Open app → 3. Name yourself → 4. Set timezone
→ 5. Add API key → 6. Start talking → 7. Watch it work
```

The onboarding walks you through everything conversationally — just like meeting a new person.

---

## 🤖 Autonomous Agent Features

### 🤖 Sub-Agent Spawning
DroidClaw can spawn **isolated sub-agents** that run their own reasoning loops in parallel. For complex tasks, it automatically suggests splitting work across multiple agents.

```
You: "Research Flutter vs React Native and also check my calendar"
DroidClaw: *Spawns two sub-agents — one for research, one for calendar*
```

### 🔧 Auto-Tool Creation
When DroidClaw encounters a task it doesn't have a tool for, it **creates one on the fly**:

```
You: "Post to my Instagram"
DroidClaw: *No Instagram tool exists*
DroidClaw: *Analyzes the task, creates instagram_post tool*
DroidClaw: *Registers it dynamically, executes it*
DroidClaw: "✅ Instagram post created!"
```

### ⚡ Auto-Skill Creation
Same for skills — if you ask it to do something it doesn't have a skill for:

```
You: "Write me a grant proposal"
DroidClaw: *No grant writing skill exists*
DroidClaw: *Creates grant_writer skill with triggers, system prompt, category*
DroidClaw: *Uses it and remembers for next time*
```

### 🔬 Deep Research Engine
Multi-layer research that goes deep:

```
You: "Research the impact of AI on healthcare"
DroidClaw:
  🔍 Layer 1: Generates research questions
  📚 Layer 2: Searches + fetches top sources
  🧠 Layer 3: Generates follow-up questions
  📚 Layer 4: Deeper investigation
  📝 Final: Synthesizes comprehensive report with citations
```

### 💓 Proactive Heartbeat
DroidClaw checks things **without being asked**:
- 📅 Upcoming calendar events
- 🔋 Low battery warnings
- 🌧️ Severe weather alerts
- Configurable interval (default: 30 min)
- Quiet hours (won't bother you at night)

### 🖼️ Multi-Modal Processing
Send it **anything** and it understands:
- 📸 **Images** → describe, OCR text, analyze, identify objects
- 🎤 **Voice notes** → transcribe, analyze, extract commands
- 📄 **Documents** → read, summarize, extract data
- Auto-detects file type and processes accordingly

---

## 🔧 90+ Tools — Complete List

### 📁 File System (8)
| Tool | Description |
|------|-------------|
| `read_file` | Read file contents |
| `write_file` | Write content to file |
| `list_dir` | List directory contents |
| `search_files` | Search for files by pattern |
| `delete_file` | Delete file/folder |
| `move_file` | Move/rename file |
| `copy_file` | Copy file |
| `file_info` | Get file details |

### 🌐 Web (5)
| Tool | Description |
|------|-------------|
| `web_search` | Search the web (DuckDuckGo) |
| `fetch_url` | Fetch and extract URL content |
| `browse_web` | Open URL in browser |
| `download_file_url` | Download file from URL |
| `screenshot_web` | Screenshot a webpage |

### 🌐 Browser Automation (20)
| Tool | Description |
|------|-------------|
| `browser_open` | Open URL in automated browser |
| `browser_navigate` | Navigate to URL |
| `browser_click` | Click element by selector/text |
| `browser_type` | Type text into input field |
| `browser_select` | Select dropdown option |
| `browser_scroll` | Scroll page up/down |
| `browser_fill_form` | Fill multiple form fields |
| `browser_screenshot` | Capture page screenshot |
| `browser_get_text` | Extract text from elements |
| `browser_get_html` | Get page/element HTML |
| `browser_get_url` | Get current page URL |
| `browser_execute_js` | Execute JavaScript on page |
| `browser_extract_links` | Extract all links as JSON |
| `browser_extract_table` | Extract tables as JSON |
| `browser_login` | Automated login flow |
| `browser_search` | Search on any website |
| `browser_wait` | Wait for elements to appear |
| `browser_multi_step` | Run multi-step automation |
| `browser_close` | Close browser |
| `browser_download` | Download file from page |

### 📞 Calls & Contacts (8)
| Tool | Description |
|------|-------------|
| `make_call` | Make a phone call |
| `end_call` | End current call |
| `answer_call` | Answer incoming call |
| `reject_call` | Reject incoming call |
| `get_call_log` | Get call history |
| `get_contacts` | Get contacts list |
| `add_contact` | Add new contact |
| `block_contact` | Block a number |

### 💬 Messaging (7)
| Tool | Description |
|------|-------------|
| `send_sms` | Send text message |
| `read_sms` | Read SMS messages |
| `send_email` | Send email |
| `send_whatsapp` | Send WhatsApp message |
| `send_telegram` | Send Telegram message |
| `share_content` | Share to any app |
| `broadcast_sms` | Send SMS to multiple contacts |

### ⏰ Scheduling (8)
| Tool | Description |
|------|-------------|
| `set_alarm` | Set alarm with days, label |
| `delete_alarm` | Delete an alarm |
| `get_alarms` | List all alarms |
| `start_timer` | Start countdown timer |
| `stop_timer` | Stop running timer |
| `set_reminder` | Set a reminder |
| `get_calendar` | Get calendar events |
| `add_calendar` | Add calendar event |

### 📱 Phone Control (20)
| Tool | Description |
|------|-------------|
| `set_brightness` | Set screen brightness |
| `get_brightness` | Get current brightness |
| `set_volume` | Set volume level |
| `get_volume` | Get volume level |
| `toggle_wifi` | Toggle WiFi |
| `get_wifi_info` | Get WiFi status |
| `toggle_bluetooth` | Toggle Bluetooth |
| `toggle_mobile_data` | Toggle mobile data |
| `toggle_airplane_mode` | Toggle airplane mode |
| `toggle_flashlight` | Toggle flashlight |
| `toggle_hotspot` | Toggle WiFi hotspot |
| `toggle_do_not_disturb` | Toggle DND mode |
| `toggle_auto_rotate` | Toggle auto-rotate |
| `set_screen_timeout` | Set screen off time |
| `lock_screen` | Lock the screen |
| `take_screenshot` | Take a screenshot |
| `record_screen` | Record screen |
| `set_wallpaper` | Set wallpaper |
| `set_ringtone` | Set ringtone |
| `vibrate` | Vibrate device |

### 📱 App Management (6)
| Tool | Description |
|------|-------------|
| `open_app` | Open any app |
| `close_app` | Force close app |
| `list_apps` | List installed apps |
| `install_app` | Install APK |
| `uninstall_app` | Uninstall app |
| `app_info` | Get app details |

### 📍 Location & Maps (5)
| Tool | Description |
|------|-------------|
| `get_location` | Get GPS location |
| `get_address` | Get address from coordinates |
| `open_maps` | Open maps with directions |
| `share_location` | Share live location |
| `geofence` | Set location alert |

### 📸 Camera & Media (8)
| Tool | Description |
|------|-------------|
| `take_photo` | Take a photo |
| `record_video` | Record video |
| `get_gallery` | Get photos from gallery |
| `delete_photo` | Delete a photo |
| `scan_qr` | Scan QR/barcode |
| `generate_qr` | Generate QR code |
| `get_storage_info` | Get storage usage |
| `screen_brightness_auto` | Auto brightness |

### 🔊 Media Playback (5)
| Tool | Description |
|------|-------------|
| `play_music` | Play audio file |
| `pause_music` | Pause playback |
| `stop_music` | Stop playback |
| `next_track` | Next track |
| `text_to_speech` | Speak text aloud |

### 🔐 Security (4)
| Tool | Description |
|------|-------------|
| `authenticate` | Biometric authentication |
| `check_biometric` | Check biometric availability |
| `encrypt_data` | Encrypt data |
| `decrypt_data` | Decrypt data |

### 📊 Device Info (6)
| Tool | Description |
|------|-------------|
| `get_device_info` | Full device info |
| `get_battery` | Battery level & status |
| `get_network_info` | Network & IP info |
| `get_running_processes` | Running processes |
| `get_system_settings` | System settings |
| `vibrate` | Vibrate device |

### 🖥️ Remote Control (10)
| Tool | Description |
|------|-------------|
| `remote_connect` | Connect to remote device (SSH) |
| `remote_disconnect` | Disconnect |
| `remote_shell` | Run command on remote |
| `remote_file_read` | Read file from remote |
| `remote_file_write` | Write file to remote |
| `remote_file_list` | List remote files |
| `remote_screenshot` | Screenshot remote screen |
| `remote_keyboard` | Send keystrokes |
| `remote_mouse` | Move/click mouse |
| `remote_clipboard` | Get/set clipboard |

### 💻 Code Execution (4)
| Tool | Description |
|------|-------------|
| `run_code` | Execute code in sandbox |
| `run_shell` | Run shell command |
| `run_python` | Run Python script |
| `run_js` | Run JavaScript |

### 🧠 Memory (4)
| Tool | Description |
|------|-------------|
| `remember` | Save to long-term memory |
| `recall` | Search memory |
| `forget` | Delete memory entry |
| `list_memories` | List all memories |

### 🔗 Integration (5)
| Tool | Description |
|------|-------------|
| `http_request` | Make HTTP API call |
| `create_note` | Create a note |
| `create_todo` | Create todo item |
| `translate_text` | Translate text |
| `clipboard_copy` | Copy to clipboard |

### 🤖 Meta: Sub-Agents & Auto-Creation (9)
| Tool | Description |
|------|-------------|
| `spawn_agent` | Spawn sub-agent for parallel tasks |
| `list_agents` | List all running sub-agents |
| `kill_agent` | Kill a sub-agent |
| `steer_agent` | Send message to sub-agent |
| `deep_research` | Multi-step deep research |
| `create_tool` | Auto-create a new tool |
| `create_skill` | Auto-create a new skill |
| `list_created_tools` | List auto-created tools |
| `list_created_skills` | List auto-created skills |

### 🖼️ Multi-Modal (4)
| Tool | Description |
|------|-------------|
| `process_image` | Analyze/OCR/describe images |
| `process_voice` | Transcribe/analyze voice notes |
| `process_document` | Read/summarize documents |
| `process_any` | Auto-detect and process any file |

### 🎨 Workflow (5)
| Tool | Description |
|------|-------------|
| `create_workflow` | Create automation workflow |
| `create_workflow_nl` | Create workflow from description |
| `run_workflow` | Run a workflow |
| `list_workflows` | List all workflows |
| `list_workflow_templates` | List workflow templates |

### 🎮 External (3)
| Tool | Description |
|------|-------------|
| `read_nfc` | Read NFC tag |
| `write_nfc` | Write NFC tag |
| `control_smart_home` | Control smart devices |

**Total: 90+ tools and growing!**

---

## ⚡ 110+ Skills — Complete List

### 💻 Development (15)
Code Review, Code Explainer, Code Converter, Code Generator, Debugger, Refactorer, Test Generator, API Designer, SQL Generator, Regex Builder, Git Helper, Docker Helper, JSON Formatter, Code Optimizer, Error Decoder

### ✍️ Writing (15)
Email Writer, Essay Writer, Story Writer, Poet, Report Writer, Cover Letter, Resume Builder, Grammar Check, Summarizer, Translator (100+ languages), Paraphraser, Headline Generator, Blog Writer, Slogan Creator, Script Writer

### 📊 Analysis (10)
Data Analyzer, Sentiment Analysis, Market Research, SWOT Analysis, Risk Assessment, Comparator, Brainstormer, Critic, Researcher, Trend Analyzer

### 🎓 Education (10)
Math Solver, Science Explainer, Historian, Flashcard Maker, Quiz Generator, ELI5, Study Planner, Language Tutor, Concept Explainer, Vocabulary Builder

### 💼 Business (10)
Business Plan, Pitch Deck, Meeting Notes, Project Planner, Budget Helper, Contract Review, Strategy Advisor, Presentation Maker, Invoice Generator, KPI Tracker

### 🎨 Creative (10)
Logo Ideas, Color Palette, UI Advisor, Brand Namer, Recipe Creator, Travel Planner, Gift Advisor, Interior Design, Fashion Advisor, Music Theory

### 🛠️ Productivity (10)
Todo Manager, Calendar Helper, Note Taker, Decision Maker, Time Manager, Habit Tracker, Goal Setter, Focus Helper, Prioritizer, Workflow Optimizer

### 🤖 AI & Tech (8)
Prompt Engineer, Tech Support, Cybersecurity, AI Explainer, Blockchain Expert, Cloud Architect, Network Expert, Database Expert

### 🏥 Health (5)
Fitness Coach, Nutrition Advisor, Wellness Guide, Sleep Advisor, Meditation Guide

### 🎮 Fun (8)
Trivia Master, Comedian, Riddler, Game Designer, Debater, Roleplayer, Story Game, Would You Rather

### 📱 Social Media (6)
Tweet Writer, Instagram Caption, LinkedIn Posts, YouTube Scripts, TikTok Ideas, Social Strategy

### 🔬 Research (5)
Academic Writer, Literature Review, Hypothesis Generator, Citation Helper, Methodology Advisor

### ⚖️ Legal (3)
Legal Basics, Privacy Advisor, Terms Writer

---

## 🎨 Workflow Templates

DroidClaw includes **6 built-in workflow templates** and can create workflows from natural language:

| Template | Description |
|----------|-------------|
| ☀️ **Daily Briefing** | Every morning: calendar + weather + news summary |
| 📱 **Social Media Post** | Create and post content across platforms |
| 🔬 **Research Report** | Deep research with final synthesized report |
| 📁 **File Organizer** | Organize files by type, date, or content |
| 📧 **Email Drafter** | Draft professional emails from context |
| 📈 **Market Monitor** | Track stocks/crypto and alert on big moves |

### Create from Natural Language
```
You: "Every morning at 8am, check my calendar, get the weather, and send me a summary"
DroidClaw: *Creates workflow with 3 steps, schedules it*
```

---

## 🤖 35+ AI Providers

| Provider | Models | Type |
|----------|--------|------|
| 🟢 OpenAI | GPT-4o, GPT-4o Mini, o1, o3-mini | Cloud |
| 🟣 Anthropic | Claude Sonnet 4, Claude 3.5 Sonnet/Haiku | Cloud |
| 🔵 Google AI | Gemini 2.5 Pro/Flash, 2.0 Flash | Cloud |
| 🔗 OpenRouter | 100+ models (all providers) | Cloud |
| 🟢 Nvidia NIM | Llama 3.1 405B/70B, DeepSeek R1 | Cloud |
| 🟠 Mistral | Large, Medium, Small, Codestral | Cloud |
| 🔷 DeepSeek | V3, Coder, R1 Reasoner | Cloud |
| 🟤 Alibaba | Qwen Max/Plus/Turbo/VL/Coder | Cloud |
| 📱 Xiaomi | MiMo V2 Pro, V2 Lite | Cloud |
| 🔥 Groq | Llama 3.1/3.3 70B, DeepSeek R1 | Cloud |
| 🟡 Cohere | Command R+, R, A | Cloud |
| 🟪 Perplexity | Sonar Pro, Sonar Large/Small | Cloud |
| 🌐 Together AI | Llama 3.1 405B, DeepSeek R1 | Cloud |
| 🧠 Cerebras | Llama 3.1/3.3 8B/70B | Cloud |
| 🟤 SambaNova | Llama 3.1 405B, DeepSeek R1 | Cloud |
| 🆆 Fireworks | Llama 3.1 405B, DeepSeek R1 | Cloud |
| ✍️ Writer | Palmyra X 004 | Cloud |
| 🟦 Replicate | Llama 3.1 405B/70B | Cloud |
| 🟩 AWS Bedrock | Claude 3.5, Llama 3.1 | Cloud |
| 🔶 Google Vertex | Gemini 2.5 Pro | Cloud |
| 🌙 Moonshot | Kimi 128K, 32K | Cloud |
| 🟫 Zhipu | GLM-4 Plus, Flash | Cloud |
| 🔶 Baichuan | Baichuan 4, 3 Turbo | Cloud |
| 🟨 Yi 01.AI | Yi Large, Medium, Vision | Cloud |
| 🟥 MiniMax | Abab 6.5 | Cloud |

### Local Models (Offline)
| Family | Models | Size |
|--------|--------|------|
| 🦙 Llama | 3.2 1B/3B, 3.1 8B | 700MB - 4.7GB |
| 🔵 Gemma | 1B, 4B, 12B, 27B | 800MB - 16GB |
| 🟦 Phi | Phi-4 Mini, Phi-3.5 Mini | 2.3-2.4GB |
| 🟤 Qwen | 0.5B - 7B | 400MB - 4.5GB |
| 🟠 Mistral | 7B, Nemo 12B | 4.1-7GB |
| 🔷 DeepSeek R1 | 1.5B, 7B | 1.1-4.5GB |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DroidClaw Gateway (Brain)                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Provider  │  │  Agent   │  │  Sub-    │  │  Auto-   │       │
│  │ Manager   │──│ Runtime  │──│  Agent   │──│  Creator │       │
│  │ (35+ AI)  │  │ (Loop)   │  │  Manager │  │  Engine  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│       │             │             │             │                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Tool    │  │  Skill   │  │ Browser  │  │ Research │       │
│  │  Engine  │  │  Engine  │  │  Engine  │  │  Engine  │       │
│  │ (90+)    │  │ (110+)   │  │ (WebView)│  │ (Deep)   │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│       │             │             │             │                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Multi-  │  │ Workflow │  │ Heartbeat│  │ Stream-  │       │
│  │  Modal   │  │  Builder │  │  Engine  │  │  ing     │       │
│  │  Engine  │  │ (Visual) │  │ (Proact.)│  │  Engine  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│       │             │             │             │                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Voice   │  │  Memory  │  │  File    │  │  Local   │       │
│  │  Engine  │  │  Engine  │  │  Manager │  │  Models  │       │
│  │ (STT/TTS)│  │ (SQLite) │  │          │  │ (20+)    │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 UI Screens

| Screen | Description |
|--------|-------------|
| 💬 **Chat** | Main agent conversation with tool tracking |
| 📊 **Dashboard** | Live status of agents, tools, memory, heartbeat |
| ⚡ **Skills** | Browse, search, enable/disable 110+ skills |
| 🔧 **Tools** | View all 90+ tools by category |
| 🌐 **Browser** | Live WebView with URL bar and console |
| 🧠 **Memory** | Long-term memory entries and knowledge base |
| 🔄 **Automation** | Cron jobs, reminders, IFTTT rules |
| ⚙️ **Settings** | API keys, providers, voice, security, appearance |

---

## 🛠️ Build From Source

### Prerequisites
```bash
# Flutter SDK 3.x
brew install flutter  # macOS
snap install flutter --classic  # Linux

# Android Studio
# Download from https://developer.android.com/studio

# Java 17
brew install openjdk@17  # macOS
```

### Build
```bash
# Clone
git clone https://github.com/Atum246/droidclaw.git
cd droidclaw

# Dependencies
flutter pub get

# Debug build
flutter run

# Release APK
flutter build apk --release

# Split APKs (smaller per-architecture)
flutter build apk --release --split-per-abi

# Output
ls build/app/outputs/flutter-apk/
```

### GitHub Actions CI/CD
Every push to `main` automatically builds the APK. Tag a release with `v*` to:
- Build universal + split APKs
- Create GitHub Release with APKs attached
- Download from Actions tab or Releases tab

---

## ⚙️ Configuration

### API Keys
1. Open DroidClaw → Settings ⚙️
2. Go to **API Keys**
3. Enter keys for your providers:
   - OpenAI: `sk-...`
   - Anthropic: `sk-ant-...`
   - Google: `AIza...`
   - OpenRouter: `sk-or-...`
   - Any of the 35+ supported providers

### Local Models (Offline)
1. Settings → **Local Models**
2. Browse available models (Llama, Gemma, Phi, Qwen, etc.)
3. Download one (e.g., Gemma 3 4B)
4. Set as active model
5. Chat without internet!

### Remote Control
1. Enable SSH on your laptop/PC
2. Use `remote_connect` tool
3. Enter host, port, credentials
4. Control your computer from your phone!

---

## 📂 Project Structure

```
droidclaw/
├── lib/
│   ├── main.dart                              # Entry point
│   ├── core/
│   │   ├── gateway/droidclaw_gateway.dart     # 🧠 Autonomous brain
│   │   ├── providers/ai_provider_manager.dart # 🤖 35+ AI providers
│   │   ├── tools/tool_engine.dart             # 🔧 90+ tools
│   │   ├── tools/tool_creator.dart            # 🔧 Auto-create tools
│   │   ├── skills/skill_engine.dart           # ⚡ 110+ skills
│   │   ├── skills/skill_creator.dart          # ⚡ Auto-create skills
│   │   ├── agents/sub_agent_manager.dart      # 🤖 Sub-agent spawning
│   │   ├── browser/browser_engine.dart        # 🌐 Browser automation
│   │   ├── research/deep_research_engine.dart # 🔬 Deep research
│   │   ├── heartbeat/heartbeat_engine.dart    # 💓 Proactive checks
│   │   ├── streaming/streaming_engine.dart    # 📡 Real-time streaming
│   │   ├── multimodal/multimodal_engine.dart  # 🖼️ Image/voice/doc
│   │   ├── workflow/workflow_builder.dart     # 🎨 Visual workflows
│   │   ├── memory/memory_engine.dart          # 🧠 SQLite memory
│   │   ├── voice/voice_engine.dart            # 🎤 STT & TTS
│   │   ├── automation/automation_engine.dart  # 🔄 Cron & tasks
│   │   ├── search/web_search_engine.dart      # 🌐 Web search
│   │   ├── models/local_model_manager.dart    # 📥 Local models
│   │   └── files/file_manager.dart            # 📁 File management
│   └── ui/
│       ├── theme/droid_theme.dart             # 🎨 Cyberpunk theme
│       └── screens/
│           ├── home_screen.dart               # 🏠 Navigation
│           ├── chat_screen.dart               # 💬 Agent chat
│           ├── dashboard_screen.dart          # 📊 Live dashboard
│           ├── skills_screen.dart             # ⚡ Skills
│           ├── tools_screen.dart              # 🔧 Tools
│           ├── browser_screen.dart            # 🌐 Browser viewer
│           ├── memory_screen.dart             # 🧠 Memory
│           ├── automation_screen.dart         # 🔄 Automation
│           ├── settings_screen.dart           # ⚙️ Settings
│           ├── onboarding_screen.dart         # 🎉 First-run setup
│           └── local_models_screen.dart       # 📥 Downloads
├── .github/workflows/build.yml                # CI/CD
├── android/                                   # Android config
├── assets/                                    # Icons, fonts
├── pubspec.yaml                               # Dependencies
└── README.md                                  # This file
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing`
5. Open a Pull Request

---

## 📄 License

MIT License — Inspired by [OpenClaw](https://github.com/openclaw/openclaw)

---

## 🙏 Credits

- [OpenClaw](https://github.com/openclaw/openclaw) — The inspiration
- [Flutter](https://flutter.dev) — The framework
- [Ollama](https://ollama.ai) — Local model runtime
- [HuggingFace](https://huggingface.co) — Model hosting

---

<p align="center">
  <b>🤖 DroidClaw — The power of OpenClaw, in your pocket</b><br/>
  <i>Can do ANYTHING on your phone</i>
</p>

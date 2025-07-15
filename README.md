# Apple Notes Enhancer

A powerful macOS application that supercharges Apple Notes with modern note-taking features like markdown support, slash commands, formatting overlays, and command palette.

## 🌟 Features

### ⌨️ Markdown Support
- Type `# ` for titles
- Type `## ` for headings  
- Type `### ` for subheadings
- Type `- ` or `* ` for bullet lists
- Type `> ` for blockquotes
- Type `[] ` for checklists
- Type ```` for code blocks

### ⚡ Slash Commands
- `/heading` or `/h1` - Format as title
- `/subheading` or `/h2` - Format as heading
- `/h3` - Format as subheading
- `/body` - Format as body text
- `/checklist` or `/todo` - Create checklist
- `/bulletlist` - Create bulleted list
- `/numbered` - Create numbered list
- `/quote` - Create blockquote
- `/code` - Format as monospaced
- `/table` - Insert table

### 🎯 Command Palette
- Press `⌘P` in Notes to open command palette
- Type to search and execute commands
- Navigate with arrow keys, execute with Enter

### 🎨 Formatting Bar
- Floating toolbar with formatting options
- Appears near text selection
- Quick access to all formatting features

### 🔗 Enhanced Navigation
- Auto-detects when Notes app is active
- Only operates when Notes is in focus
- Seamless integration with existing Notes workflow

## 🚀 Quick Start

### Prerequisites
- macOS 13.0 or later
- Xcode 14.0 or later
- Notes app installed

### Building the App

1. **Clone or download this project**
   ```bash
   git clone <repository-url>
   cd AppleNotesEnhancer
   ```

2. **Open in Xcode**
   ```bash
   open AppleNotesEnhancer.xcodeproj
   ```

3. **Build and run**
   - Press `⌘R` in Xcode, or
   - Product → Run

### Required Permissions

When you first run the app, you'll need to grant several permissions:

1. **Accessibility Permission**
   - System Preferences → Security & Privacy → Privacy → Accessibility
   - Enable "Apple Notes Enhancer"

2. **Input Monitoring Permission** 
   - System Preferences → Security & Privacy → Privacy → Input Monitoring
   - Enable "Apple Notes Enhancer"

The app will guide you through this setup process.

## 🔧 How It Works

### Technical Architecture

Apple Notes Enhancer uses several macOS system APIs to enhance Notes:

1. **Accessibility APIs** (`NSAccessibility`)
   - Reads Notes content and UI state
   - Interacts with text fields and formatting

2. **Keyboard Event Monitoring** (`NSEvent`, `CGEvent`)
   - Monitors global keyboard input
   - Detects markdown patterns and slash commands
   - Injects formatting keyboard shortcuts

3. **UI Overlays** (`NSWindow`)
   - Creates floating formatting bar
   - Command palette interface
   - Native macOS visual effects

4. **Application Integration** (`NSWorkspace`)
   - Detects when Notes app is active
   - Only operates when Notes is in focus

### Core Components

- **`AppDelegate`** - Main app controller and permissions
- **`NotesEnhancer`** - Core logic coordinator  
- **`KeyboardMonitor`** - Global input monitoring and event injection
- **`AccessibilityManager`** - Notes app integration via accessibility
- **`FormattingOverlay`** - Floating UI components

## 🎯 Usage

### Getting Started

1. **Launch the app** - It runs in the menu bar
2. **Open Apple Notes** 
3. **Start typing** - Markdown and slash commands work automatically

### Markdown Shortcuts

In any note, type these patterns followed by a space:

```
# This becomes a title
## This becomes a heading  
### This becomes a subheading
- This becomes a bullet point
> This becomes a quote
[] This becomes a checklist
``` This becomes a code block
```

### Slash Commands

Type any of these commands followed by a space:

```
/heading - Format current line as heading
/checklist - Convert to checklist item
/table - Insert a table template
/quote - Format as blockquote
```

### Command Palette

1. Press `⌘P` while in Notes
2. Type to search available commands
3. Use arrow keys to navigate
4. Press Enter to execute

### Formatting Bar

- Automatically appears when selecting text
- Click buttons for instant formatting
- Auto-hides after use

## 🛠️ Development

### Project Structure

```
AppleNotesEnhancer/
├── AppleNotesEnhancer/
│   ├── AppDelegate.swift          # Main app delegate
│   ├── NotesEnhancer.swift        # Core coordinator
│   ├── KeyboardMonitor.swift      # Keyboard handling
│   ├── AccessibilityManager.swift # Notes integration
│   ├── FormattingOverlay.swift    # UI overlays
│   ├── Info.plist                 # App configuration
│   ├── *.entitlements            # Security permissions
│   └── Assets.xcassets/           # App resources
├── README.md                      # This file
└── AppleNotesEnhancer.xcodeproj/  # Xcode project
```

### Key Technologies

- **Swift 5.0** - Primary language
- **AppKit/Cocoa** - macOS UI framework
- **Accessibility APIs** - Notes integration
- **Core Graphics** - Event injection
- **Visual Effects** - Modern UI

### Building from Source

```bash
# 1. Clone repository
git clone <repository-url>
cd AppleNotesEnhancer

# 2. Open in Xcode
open AppleNotesEnhancer.xcodeproj

# 3. Set development team (if needed)
# Edit project settings → Signing & Capabilities

# 4. Build and run
# Press Cmd+R or Product → Run
```

## 📋 System Requirements

- **Operating System**: macOS 13.0+
- **Memory**: 50MB RAM
- **Disk Space**: 20MB
- **Permissions**: Accessibility, Input Monitoring
- **Dependencies**: Apple Notes app

## 🔒 Privacy & Security

- **Local Processing**: All text processing happens locally
- **No Data Collection**: No user data is transmitted or stored
- **Minimal Permissions**: Only requests necessary system access
- **Open Source**: Full source code available for inspection

## 🐛 Troubleshooting

### App Not Working

1. **Check permissions** - Both Accessibility and Input Monitoring must be enabled
2. **Restart Notes** - Close and reopen Notes app
3. **Restart enhancer** - Quit and relaunch from menu bar

### Commands Not Detected

1. **Verify Notes is active** - Click in Notes window first
2. **Type commands slowly** - Allow time for detection
3. **Check for conflicts** - Other automation tools may interfere

### Formatting Bar Not Appearing

1. **Select text first** - Highlight text before expecting bar
2. **Wait a moment** - Bar appears after brief delay
3. **Check overlays** - Ensure no other windows blocking

## 🔮 Future Enhancements

- **AI Integration** - Writing assistance and completion
- **Custom Templates** - User-defined content snippets  
- **Note Linking** - Bi-directional note connections
- **Markdown Export** - Convert notes to markdown files
- **Themes & Customization** - Personalized appearance

## 🤝 Contributing

This is an educational project demonstrating macOS app development concepts:

- Accessibility API integration
- System-level keyboard monitoring
- Floating UI overlays
- App-to-app communication

Feel free to explore, learn, and build upon this foundation!

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- Inspired by ProNotes and similar note enhancement tools
- Built using documented macOS APIs and best practices
- Educational project for learning system-level macOS development

---

**Note**: This is a demonstration project showing how to build ProNotes-like functionality using macOS APIs. It implements core features like markdown support, slash commands, and formatting overlays.

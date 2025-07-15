# 🔌 Apple Notes Enhancer - User Guide

## 📥 Installation

### Step 1: Download & Install
1. **Download** the latest release from [GitHub Releases](https://github.com/your-username/apple-notes-enhancer/releases/latest)
2. **Extract** the ZIP file
3. **Drag** `Apple Notes Enhancer.app` to your `/Applications` folder
4. **Launch** the app by double-clicking it

### Step 2: Grant Permissions
The app will request two essential permissions:

#### Accessibility Permission
1. System Preferences will open automatically
2. Go to **Security & Privacy** → **Privacy** → **Accessibility**
3. Click the **lock** to make changes (enter your password)
4. **Check the box** next to "Apple Notes Enhancer"

#### Input Monitoring Permission  
1. Go to **Security & Privacy** → **Privacy** → **Input Monitoring**
2. Click the **lock** to make changes
3. **Check the box** next to "Apple Notes Enhancer"

### Step 3: Verify Installation
1. Look for the **Notes Enhancer icon** in your menu bar (top right)
2. Open **Apple Notes**
3. Type `# Hello World` - it should automatically format as a heading!

---

## 🚀 Getting Started

### Basic Usage
1. **Open Apple Notes** (the plugin only works when Notes is active)
2. **Create a new note** or open an existing one
3. **Start typing** with the shortcuts below
4. The plugin works **automatically** in the background

### Menu Bar Controls
Click the Notes Enhancer icon in your menu bar to:
- ✅ Check plugin status
- 🔧 Open Apple Notes quickly
- ⚙️ Verify permissions
- ❌ Quit the plugin

---

## ⌨️ Markdown Shortcuts

Type these patterns and they'll **automatically format** as you type:

### Headings
```
# Large Heading          → Formats as Title
## Medium Heading        → Formats as Heading  
### Small Heading        → Formats as Subheading
```

### Lists
```
- Bullet point           → Creates bulleted list
* Another bullet         → Creates bulleted list
1. Numbered item         → Creates numbered list
2. Next numbered item    → Continues numbering
```

### Other Formatting
```
> This is a quote        → Creates blockquote style
[] Checklist item        → Creates checkbox list
`code text`              → Formats as monospace
```

### Code Blocks
```
```
Type code here
```                      → Creates code block
```

---

## ⚡ Slash Commands

Type `/` followed by a command for instant formatting:

### Text Formatting
- `/heading` or `/h1` → Convert to title
- `/subheading` or `/h2` → Convert to heading  
- `/h3` → Convert to subheading
- `/body` → Convert to body text
- `/code` → Format as monospace

### Lists & Structure
- `/checklist` or `/todo` → Create checklist
- `/bulletlist` → Create bulleted list
- `/numbered` → Create numbered list
- `/quote` → Create blockquote

### Special Features
- `/table` → Insert table structure
- `/date` → Insert current date
- `/time` → Insert current time

### How to Use Slash Commands
1. Type `/` in Notes
2. Continue typing the command (e.g., `/heading`)
3. Press **Space** or **Enter** to execute
4. The text will be formatted automatically

---

## 🎯 Command Palette

Press **⌘P** (Cmd+P) while in Apple Notes to open the command palette.

### Available Commands
- **Format as Heading** → Make selected text a heading
- **Create Checklist** → Convert text to checklist
- **Make Quote** → Format as blockquote
- **Insert Table** → Add table structure
- **Bold Text** → Make selection bold
- **Italic Text** → Make selection italic
- **Code Format** → Format as code

### Using the Command Palette
1. **Select text** in Notes (optional)
2. Press **⌘P**
3. **Type** to search commands
4. Use **↑↓** arrow keys to navigate
5. Press **Enter** to execute

---

## 🎨 Visual Formatting Toolbar

When you **select text** in Notes, a formatting toolbar appears automatically.

### Toolbar Features
- **B** → Bold
- **I** → Italic  
- **H1, H2, H3** → Heading levels
- **Quote** → Blockquote
- **List** → Bullet list
- **Check** → Checklist
- **Code** → Monospace

### Using the Toolbar
1. **Highlight text** in your note
2. **Wait a moment** for the toolbar to appear
3. **Click** any formatting button
4. Text is formatted instantly

---

## 💡 Tips & Tricks

### Productivity Shortcuts
- **⌘P** → Quick command access
- **Type markdown** → Instant formatting
- **Select + toolbar** → Visual formatting
- **Slash commands** → Fast structure creation

### Best Practices
1. **Keep the plugin running** - it works in the background
2. **Click in Notes first** - ensure Notes is the active app
3. **Type naturally** - markdown shortcuts work as you type
4. **Use command palette** for complex formatting

### Combining Features
- Start with **markdown shortcuts** for speed
- Use **slash commands** for structure
- Use **command palette** for advanced formatting
- Use **toolbar** for visual feedback

---

## 🔧 Troubleshooting

### Plugin Not Working

**Problem**: Commands not being detected
**Solutions**:
1. ✅ Verify Notes app is **active** (click in Notes window)
2. ✅ Check **permissions** are granted (menu bar → Check Permissions)
3. ✅ **Restart** the plugin (menu bar → Quit, then relaunch)
4. ✅ **Restart Notes** app completely

### Formatting Not Applied

**Problem**: Markdown shortcuts not working
**Solutions**:
1. ✅ Type **slowly** - allow time for detection
2. ✅ Ensure **space** after markdown patterns (e.g., `# ` with space)
3. ✅ Check for **conflicting apps** (other automation tools)
4. ✅ Try the **command palette** (⌘P) as alternative

### Toolbar Not Appearing

**Problem**: Visual toolbar doesn't show
**Solutions**:
1. ✅ **Select text first** - toolbar appears after selection
2. ✅ **Wait 1-2 seconds** - there's a brief delay
3. ✅ Check **screen position** - toolbar may be off-screen
4. ✅ Try **different text selection** sizes

### Permission Issues

**Problem**: System asking for permissions repeatedly
**Solutions**:
1. ✅ **Completely quit** the app first
2. ✅ **Remove** from Privacy settings
3. ✅ **Re-add** to both Accessibility and Input Monitoring
4. ✅ **Relaunch** the plugin

---

## 📋 Quick Reference

### Essential Shortcuts
| Action | Method 1 | Method 2 | Method 3 |
|--------|----------|----------|----------|
| **Heading** | Type `# ` | `/heading` | ⌘P → "Format as Heading" |
| **List** | Type `- ` | `/bulletlist` | Select text + toolbar |
| **Quote** | Type `> ` | `/quote` | ⌘P → "Make Quote" |
| **Checklist** | Type `[] ` | `/checklist` | Select text + toolbar |
| **Command Palette** | ⌘P | - | - |

### Keyboard Shortcuts
- **⌘P** → Command palette
- **⌘N** → New note (Notes app)
- **⌘T** → New note in same window

---

## 🎉 Advanced Usage

### Creating Templates
Use slash commands to quickly create note templates:

```
/heading
Project Meeting Notes

/subheading  
Attendees
/bulletlist
- Person 1
- Person 2

/subheading
Action Items
/checklist
- Task 1
- Task 2

/subheading
Notes
/quote
Key decisions made...
```

### Workflow Integration
1. **Quick notes**: Use markdown shortcuts for speed
2. **Structured content**: Start with slash commands
3. **Final formatting**: Use command palette for polish
4. **Visual editing**: Use toolbar for fine-tuning

---

## ❓ FAQ

**Q: Does this modify Apple Notes app?**
A: No, it works alongside Notes without modifying the app itself.

**Q: Is my data safe?**
A: Yes, all processing happens locally on your Mac. No data is sent anywhere.

**Q: Can I use this with other note apps?**
A: Currently only works with Apple Notes, but could be extended to other apps.

**Q: Does it work with iCloud sync?**
A: Yes, the formatted notes sync normally through iCloud.

**Q: Can I disable specific features?**
A: Currently all features are enabled. Future versions may add customization.

---

## 🚀 What's Next?

Now that you know how to use Apple Notes Enhancer:

1. **Experiment** with different markdown shortcuts
2. **Try the command palette** (⌘P) for quick actions  
3. **Use slash commands** to structure your notes
4. **Combine features** for maximum productivity

**Happy note-taking!** 📝✨
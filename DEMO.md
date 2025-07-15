# Apple Notes Enhancer Demo

Welcome to Apple Notes Enhancer! This demo shows all the features you can use in Apple Notes.

## 🎯 Quick Start Guide

1. **Install the app** - Run the build script: `./build.sh`
2. **Grant permissions** - Enable Accessibility and Input Monitoring
3. **Open Apple Notes** - Start a new note
4. **Try the examples below!**

---

## ⌨️ Markdown Support

### Try typing these patterns (followed by a space):

```
# This becomes a title
## This becomes a heading
### This becomes a subheading
```

**Lists:**
```
- This becomes a bullet point
* This also becomes a bullet point
1. This becomes a numbered list item
```

**Special formatting:**
```
> This becomes a blockquote
[] This becomes a checklist item
``` This becomes a code block
```

---

## ⚡ Slash Commands

### Type these commands followed by a space:

- `/heading` - Format as heading
- `/subheading` - Format as subheading  
- `/body` - Format as body text
- `/checklist` - Create checklist
- `/bulletlist` - Create bulleted list
- `/numbered` - Create numbered list
- `/quote` - Create blockquote
- `/code` - Format as monospaced
- `/table` - Insert table template

---

## 🎯 Command Palette

**Press ⌘P in Notes to open the command palette**

Then try:
- Type "heading" to find heading commands
- Type "list" to find list commands
- Type "table" to insert a table
- Use arrow keys to navigate
- Press Enter to execute

---

## 🎨 Formatting Bar

**Select any text in Notes to see the formatting bar**

The floating toolbar appears automatically and includes:
- **B** - Bold
- **I** - Italic  
- **U** - Underline
- **T1** - Title format
- **T2** - Heading format
- **T3** - Subheading format
- **●** - Bulleted list
- **✓** - Checklist
- **🔗** - Insert link
- **⊞** - Insert table

---

## 📝 Example Note

Copy this into Apple Notes to test the features:

```
# My Enhanced Note

## Introduction
This note was created with Apple Notes Enhancer!

### Features I love:
- Instant markdown support
- Slash commands
- Command palette with ⌘P
- Floating formatting bar

### My Todo List:
[] Learn all the shortcuts
[] Try the command palette
[] Test markdown formatting
[] Share with friends

### Code Example:
```
function enhanceNotes() {
    return "Amazing!";
}
```

> "Apple Notes Enhancer makes note-taking so much better!" 
> - Happy User

### Quick Table:
| Feature | Shortcut | Status |
|---------|----------|--------|
| Markdown | Type patterns | ✅ |
| Slash Commands | /command | ✅ |
| Command Palette | ⌘P | ✅ |
```

---

## 🔧 Technical Details

### How it works:
1. **Monitors keyboard input** when Notes is active
2. **Detects markdown patterns** like `# ` and `- `
3. **Converts to Notes formatting** using keyboard shortcuts
4. **Shows helpful UI overlays** for enhanced productivity

### Permissions needed:
- **Accessibility** - To read/write Notes content
- **Input Monitoring** - To detect typing patterns

### Privacy:
- ✅ All processing is local
- ✅ No data sent to servers
- ✅ Only active when Notes is focused

---

## 🚀 Try It Now!

1. **Open Apple Notes**
2. **Start a new note**
3. **Type:** `# Hello World` (then space)
4. **Watch it become a title!**
5. **Press ⌘P** to open command palette
6. **Select some text** to see formatting bar

---

## 📚 Full Command Reference

### Markdown Patterns:
- `# ` → Title
- `## ` → Heading
- `### ` → Subheading
- `- ` → Bullet list
- `* ` → Bullet list
- `1. ` → Numbered list
- `> ` → Blockquote
- `[] ` → Checklist
- ```` → Code block

### Slash Commands:
- `/heading` or `/h1` → Title
- `/subheading` or `/h2` → Heading
- `/h3` → Subheading
- `/body` → Body text
- `/checklist` or `/todo` → Checklist
- `/bulletlist` → Bulleted list
- `/numbered` → Numbered list
- `/quote` → Blockquote
- `/code` → Monospaced
- `/table` → Insert table

### Keyboard Shortcuts:
- `⌘P` → Command palette
- `⌘⇧M` → Convert to markdown

---

## 🎉 Have Fun!

Apple Notes Enhancer transforms your note-taking experience. Try all the features and see how much more productive you can be!

**Questions?** Check the README.md file for troubleshooting and technical details.
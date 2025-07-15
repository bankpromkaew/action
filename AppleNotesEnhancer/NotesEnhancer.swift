import Cocoa
import ApplicationServices

class NotesEnhancer {
    
    private var keyboardMonitor: KeyboardMonitor?
    private var accessibilityManager: AccessibilityManager?
    private var formattingOverlay: FormattingOverlay?
    
    private var isActive = false
    private var isNotesActive = false
    
    // Current text buffer for command detection
    private var textBuffer = ""
    private let maxBufferLength = 50
    
    // MARK: - Lifecycle
    
    func start() {
        guard !isActive else { return }
        
        print("🔧 Starting Notes Enhancer components...")
        
        // Initialize components
        keyboardMonitor = KeyboardMonitor()
        accessibilityManager = AccessibilityManager()
        formattingOverlay = FormattingOverlay()
        
        // Set up keyboard monitoring
        keyboardMonitor?.onKeyPressed = { [weak self] in
            self?.handleKeyPress($0, modifiers: $1)
        }
        
        // Set up app monitoring
        setupAppMonitoring()
        
        // Start monitoring
        keyboardMonitor?.start()
        
        isActive = true
        print("✅ Notes Enhancer started successfully")
    }
    
    func stop() {
        guard isActive else { return }
        
        keyboardMonitor?.stop()
        formattingOverlay?.hide()
        
        isActive = false
        print("🛑 Notes Enhancer stopped")
    }
    
    // MARK: - App Monitoring
    
    private func setupAppMonitoring() {
        // Monitor app switching
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppActivated(notification)
        }
        
        // Check current app
        updateNotesActiveStatus()
    }
    
    private func handleAppActivated(_ notification: Notification) {
        updateNotesActiveStatus()
    }
    
    private func updateNotesActiveStatus() {
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        let wasActive = isNotesActive
        isNotesActive = frontmostApp?.bundleIdentifier == "com.apple.Notes"
        
        if isNotesActive && !wasActive {
            print("📝 Notes app activated - enhancer features enabled")
            textBuffer = "" // Reset buffer when switching to Notes
        } else if !isNotesActive && wasActive {
            print("📱 Notes app deactivated - hiding overlays")
            formattingOverlay?.hide()
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func handleKeyPress(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        guard isNotesActive else { return }
        
        // Handle special key combinations first
        if handleSpecialKeyCombinations(keyCode: keyCode, modifiers: modifiers) {
            return
        }
        
        // Update text buffer for command detection
        updateTextBuffer(keyCode: keyCode, modifiers: modifiers)
        
        // Check for commands
        processTextBuffer()
    }
    
    private func handleSpecialKeyCombinations(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // Command+P for command palette
        if modifiers.contains(.command) && keyCode == 35 { // P key
            showCommandPalette()
            return true
        }
        
        // Command+Shift+M for markdown conversion
        if modifiers.contains([.command, .shift]) && keyCode == 46 { // M key
            convertToMarkdown()
            return true
        }
        
        return false
    }
    
    private func updateTextBuffer(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        // Only track regular character input
        guard !modifiers.contains(.command) && !modifiers.contains(.control) else {
            return
        }
        
        // Convert key code to character
        if let character = KeyboardMonitor.keyCodeToCharacter(keyCode) {
            textBuffer.append(character)
            
            // Keep buffer size manageable
            if textBuffer.count > maxBufferLength {
                textBuffer = String(textBuffer.suffix(maxBufferLength))
            }
        }
        
        // Clear buffer on certain keys
        if keyCode == 36 || keyCode == 48 { // Enter or Tab
            textBuffer = ""
        }
    }
    
    // MARK: - Command Processing
    
    private func processTextBuffer() {
        // Check for slash commands
        if let slashCommand = detectSlashCommand() {
            executeSlashCommand(slashCommand)
            return
        }
        
        // Check for markdown patterns
        if let markdownPattern = detectMarkdownPattern() {
            applyMarkdownFormatting(markdownPattern)
            return
        }
    }
    
    private func detectSlashCommand() -> String? {
        let commands = [
            "/heading", "/h1", "/title",
            "/subheading", "/h2",
            "/h3", "/subhead",
            "/body", "/normal",
            "/checklist", "/todo",
            "/bulletlist", "/bulleted",
            "/numbered", "/numberedlist",
            "/quote", "/blockquote",
            "/code", "/monostyled",
            "/table"
        ]
        
        for command in commands {
            if textBuffer.hasSuffix(command + " ") {
                return command
            }
        }
        
        return nil
    }
    
    private func detectMarkdownPattern() -> String? {
        let patterns = [
            "# ", "## ", "### ",  // Headers
            "- ", "* ",           // Lists
            "> ",                 // Blockquote
            "```",               // Code block
            "[] "                // Checklist
        ]
        
        for pattern in patterns {
            if textBuffer.hasSuffix(pattern) {
                return pattern
            }
        }
        
        return nil
    }
    
    // MARK: - Command Execution
    
    private func executeSlashCommand(_ command: String) {
        print("⚡ Executing slash command: \(command)")
        
        // Remove the command from the text
        removeLastCharacters(command.count + 1) // +1 for the space
        
        switch command {
        case "/heading", "/h1", "/title":
            applyFormatting(.title)
        case "/subheading", "/h2":
            applyFormatting(.heading)
        case "/h3", "/subhead":
            applyFormatting(.subheading)
        case "/body", "/normal":
            applyFormatting(.body)
        case "/checklist", "/todo":
            insertChecklist()
        case "/bulletlist", "/bulleted":
            applyFormatting(.bulleted)
        case "/numbered", "/numberedlist":
            applyFormatting(.numbered)
        case "/quote", "/blockquote":
            applyFormatting(.quote)
        case "/code", "/monostyled":
            applyFormatting(.monostyled)
        case "/table":
            insertTable()
        default:
            break
        }
        
        textBuffer = ""
    }
    
    private func applyMarkdownFormatting(_ pattern: String) {
        print("🎨 Applying markdown pattern: \(pattern)")
        
        // Remove the markdown syntax
        removeLastCharacters(pattern.count)
        
        switch pattern {
        case "# ":
            applyFormatting(.title)
        case "## ":
            applyFormatting(.heading)
        case "### ":
            applyFormatting(.subheading)
        case "- ", "* ":
            applyFormatting(.bulleted)
        case "> ":
            applyFormatting(.quote)
        case "```":
            applyFormatting(.monostyled)
        case "[] ":
            insertChecklist()
        default:
            break
        }
        
        textBuffer = ""
    }
    
    // MARK: - Formatting Actions
    
    private enum FormattingStyle {
        case title, heading, subheading, body
        case bulleted, numbered, quote, monostyled
    }
    
    private func applyFormatting(_ style: FormattingStyle) {
        // This would use accessibility APIs to change formatting in Notes
        // For now, we'll simulate the keyboard shortcuts that Notes uses
        
        let keySequence: [(UInt16, NSEvent.ModifierFlags)]
        
        switch style {
        case .title:
            // Command+Shift+T for Title
            keySequence = [(17, [.command, .shift])] // T key
        case .heading:
            // Command+Shift+H for Heading
            keySequence = [(4, [.command, .shift])] // H key
        case .subheading:
            // Command+Shift+J for Subheading
            keySequence = [(38, [.command, .shift])] // J key
        case .body:
            // Command+Shift+B for Body
            keySequence = [(11, [.command, .shift])] // B key
        case .bulleted:
            // Command+Shift+8 for Bulleted list
            keySequence = [(28, [.command, .shift])] // 8 key
        case .numbered:
            // Command+Shift+7 for Numbered list
            keySequence = [(26, [.command, .shift])] // 7 key
        case .quote:
            // Command+' for Quote (if available)
            keySequence = [(39, [.command])] // ' key
        case .monostyled:
            // Command+Shift+M for Monostyled
            keySequence = [(46, [.command, .shift])] // M key
        }
        
        // Send the keyboard events
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sendKeySequence(keySequence)
        }
    }
    
    private func insertChecklist() {
        // Use Notes' checklist shortcut: Shift+Command+U
        let keySequence: [(UInt16, NSEvent.ModifierFlags)] = [(32, [.command, .shift])] // U key
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sendKeySequence(keySequence)
        }
    }
    
    private func insertTable() {
        // Insert a basic table structure
        let tableText = """
        
        | Column 1 | Column 2 | Column 3 |
        |----------|----------|----------|
        |          |          |          |
        |          |          |          |
        
        """
        
        typeText(tableText)
    }
    
    // MARK: - Text Operations
    
    private func removeLastCharacters(_ count: Int) {
        for _ in 0..<count {
            sendKeyEvent(keyCode: 51, modifiers: []) // Backspace
        }
    }
    
    private func typeText(_ text: String) {
        for character in text {
            if character == "\n" {
                sendKeyEvent(keyCode: 36, modifiers: []) // Enter
            } else {
                // For simplicity, we'll use the pasteboard
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(String(character), forType: .string)
                sendKeyEvent(keyCode: 9, modifiers: [.command]) // Command+V
            }
        }
    }
    
    private func sendKeySequence(_ sequence: [(UInt16, NSEvent.ModifierFlags)]) {
        for (keyCode, modifiers) in sequence {
            sendKeyEvent(keyCode: keyCode, modifiers: modifiers)
        }
    }
    
    private func sendKeyEvent(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        KeyboardMonitor.sendKeyEvent(keyCode: keyCode, modifiers: modifiers)
    }
    
    // MARK: - UI Actions
    
    private func showCommandPalette() {
        print("🎯 Showing command palette")
        formattingOverlay?.showCommandPalette()
    }
    
    private func convertToMarkdown() {
        print("📝 Converting selection to markdown")
        // This would get the current selection and convert it to markdown
        // Implementation depends on accessibility API integration
    }
}
import Cocoa
import ApplicationServices

class NotesEnhancer {
    
    private var keyboardMonitor: KeyboardMonitor?
    private var formattingOverlay: FormattingOverlay?
    
    private var isActive = false
    private var isNotesActive = false
    
    // Current text buffer for command detection
    private var textBuffer = ""
    private let maxBufferLength = 30
    
    // Debounce processing to avoid overwhelming the system
    private var processTimer: Timer?
    
    // MARK: - Lifecycle
    
    func start() {
        guard !isActive else { return }
        
        print("🔧 Starting Notes Enhancer components...")
        
        // Initialize components with error handling
        do {
            try initializeComponents()
            setupAppMonitoring()
            isActive = true
            print("✅ Notes Enhancer started successfully")
        } catch {
            print("❌ Failed to start Notes Enhancer: \(error)")
        }
    }
    
    private func initializeComponents() throws {
        // Initialize keyboard monitor
        keyboardMonitor = KeyboardMonitor()
        keyboardMonitor?.onKeyPressed = { [weak self] keyCode, modifiers in
            DispatchQueue.main.async {
                self?.handleKeyPress(keyCode, modifiers: modifiers)
            }
        }
        
        // Initialize formatting overlay (safe fallback)
        formattingOverlay = FormattingOverlay()
        
        // Start monitoring with error handling
        if !(keyboardMonitor?.start() ?? false) {
            throw NSError(domain: "NotesEnhancer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not start keyboard monitoring"])
        }
    }
    
    func stop() {
        guard isActive else { return }
        
        processTimer?.invalidate()
        keyboardMonitor?.stop()
        formattingOverlay?.hide()
        
        isActive = false
        print("🛑 Notes Enhancer stopped")
    }
    
    // MARK: - App Monitoring
    
    private func setupAppMonitoring() {
        // Monitor app switching safely
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
        
        // Process with debouncing to avoid overwhelming
        debounceProcessing()
    }
    
    private func handleSpecialKeyCombinations(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // Command+P for command palette
        if modifiers.contains(.command) && keyCode == 35 { // P key
            showCommandPalette()
            return true
        }
        
        return false
    }
    
    private func updateTextBuffer(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        // Only track regular character input
        guard !modifiers.contains(.command) && !modifiers.contains(.control) else {
            return
        }
        
        // Convert key code to character safely
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
    
    private func debounceProcessing() {
        processTimer?.invalidate()
        processTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.processTextBuffer()
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
            "/heading", "/h1",
            "/subheading", "/h2", 
            "/body",
            "/checklist", "/todo",
            "/bulletlist", 
            "/numbered",
            "/quote",
            "/code",
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
        
        // Remove the command from the text safely
        safelyRemoveLastCharacters(command.count + 1) // +1 for the space
        
        // Apply formatting based on command
        switch command {
        case "/heading", "/h1":
            applyFormattingSafely(.title)
        case "/subheading", "/h2":
            applyFormattingSafely(.heading)
        case "/body":
            applyFormattingSafely(.body)
        case "/checklist", "/todo":
            insertChecklistSafely()
        case "/bulletlist":
            applyFormattingSafely(.bulleted)
        case "/numbered":
            applyFormattingSafely(.numbered)
        case "/quote":
            applyFormattingSafely(.quote)
        case "/code":
            applyFormattingSafely(.monostyled)
        case "/table":
            insertTableSafely()
        default:
            break
        }
        
        textBuffer = ""
    }
    
    private func applyMarkdownFormatting(_ pattern: String) {
        print("🎨 Applying markdown pattern: \(pattern)")
        
        // Remove the markdown syntax safely
        safelyRemoveLastCharacters(pattern.count)
        
        switch pattern {
        case "# ":
            applyFormattingSafely(.title)
        case "## ":
            applyFormattingSafely(.heading)
        case "### ":
            applyFormattingSafely(.subheading)
        case "- ", "* ":
            applyFormattingSafely(.bulleted)
        case "> ":
            applyFormattingSafely(.quote)
        case "[] ":
            insertChecklistSafely()
        default:
            break
        }
        
        textBuffer = ""
    }
    
    // MARK: - Safe Formatting Actions
    
    private enum FormattingStyle {
        case title, heading, subheading, body
        case bulleted, numbered, quote, monostyled
    }
    
    private func applyFormattingSafely(_ style: FormattingStyle) {
        guard isNotesActive else { return }
        
        let keySequence: [(UInt16, NSEvent.ModifierFlags)]
        
        switch style {
        case .title:
            keySequence = [(17, [.command, .shift])] // Command+Shift+T
        case .heading:
            keySequence = [(4, [.command, .shift])]  // Command+Shift+H
        case .subheading:
            keySequence = [(38, [.command, .shift])] // Command+Shift+J
        case .body:
            keySequence = [(11, [.command, .shift])] // Command+Shift+B
        case .bulleted:
            keySequence = [(28, [.command, .shift])] // Command+Shift+8
        case .numbered:
            keySequence = [(26, [.command, .shift])] // Command+Shift+7
        case .quote:
            keySequence = [(39, [.command])]         // Command+'
        case .monostyled:
            keySequence = [(46, [.command, .shift])] // Command+Shift+M
        }
        
        // Send the keyboard events with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sendKeySequenceSafely(keySequence)
        }
    }
    
    private func insertChecklistSafely() {
        guard isNotesActive else { return }
        // Use Notes' checklist shortcut: Shift+Command+U
        let keySequence: [(UInt16, NSEvent.ModifierFlags)] = [(32, [.command, .shift])]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sendKeySequenceSafely(keySequence)
        }
    }
    
    private func insertTableSafely() {
        guard isNotesActive else { return }
        // Insert a basic table structure via clipboard
        let tableText = """
        
        | Header 1 | Header 2 | Header 3 |
        |----------|----------|----------|
        | Cell 1   | Cell 2   | Cell 3   |
        
        """
        
        typeTextSafely(tableText)
    }
    
    // MARK: - Safe Text Operations
    
    private func safelyRemoveLastCharacters(_ count: Int) {
        guard count > 0 && isNotesActive else { return }
        
        // Send backspaces with small delays
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.01) {
                KeyboardMonitor.sendKeyEventSafely(keyCode: 51, modifiers: []) // Backspace
            }
        }
    }
    
    private func typeTextSafely(_ text: String) {
        guard isNotesActive else { return }
        
        // Use clipboard method for safety
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            KeyboardMonitor.typeTextViaClipboardSafely(text)
        }
    }
    
    private func sendKeySequenceSafely(_ sequence: [(UInt16, NSEvent.ModifierFlags)]) {
        guard isNotesActive else { return }
        
        for (index, (keyCode, modifiers)) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {
                KeyboardMonitor.sendKeyEventSafely(keyCode: keyCode, modifiers: modifiers)
            }
        }
    }
    
    // MARK: - UI Actions
    
    private func showCommandPalette() {
        print("🎯 Showing command palette")
        formattingOverlay?.showCommandPalette()
    }
}
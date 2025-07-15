import Cocoa
import Carbon
import ApplicationServices

class KeyboardMonitor {
    
    // Callback for key press events
    var onKeyPressed: ((UInt16, NSEvent.ModifierFlags) -> Void)?
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isMonitoring = false
    
    // MARK: - Lifecycle
    
    func start() {
        guard !isMonitoring else { return }
        
        print("⌨️ Starting keyboard monitoring...")
        
        // Set up global event monitoring (when app is not in focus)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // Set up local event monitoring (when app is in focus)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event // Pass through the event
        }
        
        isMonitoring = true
        print("✅ Keyboard monitoring started")
    }
    
    func stop() {
        guard isMonitoring else { return }
        
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        
        isMonitoring = false
        print("🛑 Keyboard monitoring stopped")
    }
    
    // MARK: - Event Handling
    
    private func handleKeyEvent(_ event: NSEvent) {
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags
        
        // Debug logging for development
        if let character = Self.keyCodeToCharacter(keyCode) {
            let modifierString = formatModifiers(modifiers)
            let debugInfo = modifierString.isEmpty ? "\(character)" : "\(modifierString)+\(character)"
            print("🔍 Key pressed: \(debugInfo) (code: \(keyCode))")
        }
        
        // Call the callback
        onKeyPressed?(keyCode, modifiers)
    }
    
    private func formatModifiers(_ modifiers: NSEvent.ModifierFlags) -> String {
        var components: [String] = []
        
        if modifiers.contains(.command) { components.append("Cmd") }
        if modifiers.contains(.shift) { components.append("Shift") }
        if modifiers.contains(.option) { components.append("Opt") }
        if modifiers.contains(.control) { components.append("Ctrl") }
        
        return components.joined(separator: "+")
    }
    
    // MARK: - Key Code Utilities
    
    static func keyCodeToCharacter(_ keyCode: UInt16) -> String? {
        // Key code to character mapping for common keys
        let keyCodeMap: [UInt16: String] = [
            // Letters
            0: "a", 1: "s", 2: "d", 3: "f", 4: "h", 5: "g", 6: "z", 7: "x", 8: "c", 9: "v",
            11: "b", 12: "q", 13: "w", 14: "e", 15: "r", 16: "y", 17: "t", 18: "1", 19: "2",
            20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8",
            29: "0", 30: "]", 31: "o", 32: "u", 33: "[", 34: "i", 35: "p", 36: "\n", 37: "l",
            38: "j", 39: "'", 40: "k", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "n", 46: "m",
            47: ".", 48: "\t", 49: " ", 50: "`", 51: "⌫", 53: "⎋",
            
            // Function keys
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7", 100: "F8",
            101: "F9", 109: "F10", 103: "F11", 111: "F12",
            
            // Arrow keys
            123: "←", 124: "→", 125: "↓", 126: "↑",
            
            // Other special keys
            116: "Page Up", 121: "Page Down", 115: "Home", 119: "End",
            114: "Help", 117: "Delete"
        ]
        
        return keyCodeMap[keyCode]
    }
    
    // MARK: - Event Injection
    
    static func sendKeyEvent(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        print("📤 Sending key event: \(keyCode) with modifiers: \(modifiers)")
        
        // Convert NSEvent modifiers to CGEvent flags
        var cgFlags: CGEventFlags = []
        
        if modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
        if modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
        if modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
        if modifiers.contains(.control) { cgFlags.insert(.maskControl) }
        
        // Create and send key down event
        if let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) {
            keyDownEvent.flags = cgFlags
            keyDownEvent.post(tap: .cghidEventTap)
        }
        
        // Small delay between key down and key up
        usleep(10000) // 10ms
        
        // Create and send key up event
        if let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false) {
            keyUpEvent.flags = cgFlags
            keyUpEvent.post(tap: .cghidEventTap)
        }
    }
    
    static func sendTextAsKeyEvents(_ text: String) {
        print("📝 Sending text as key events: \(text)")
        
        for character in text {
            if let keyCode = characterToKeyCode(character) {
                sendKeyEvent(keyCode: keyCode, modifiers: [])
                usleep(20000) // 20ms delay between characters
            }
        }
    }
    
    private static func characterToKeyCode(_ character: Character) -> UInt16? {
        // Reverse mapping from character to key code
        let charToKeyMap: [Character: UInt16] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9,
            "b": 11, "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17,
            "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26,
            "-": 27, "8": 28, "0": 29, "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
            "l": 37, "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "n": 45,
            "m": 46, ".": 47, " ": 49, "`": 50
        ]
        
        return charToKeyMap[Character(character.lowercased())]
    }
    
    // MARK: - Special Key Methods
    
    static func sendBackspace(count: Int = 1) {
        for _ in 0..<count {
            sendKeyEvent(keyCode: 51, modifiers: []) // Backspace key
            usleep(50000) // 50ms delay between backspaces
        }
    }
    
    static func sendEnter() {
        sendKeyEvent(keyCode: 36, modifiers: []) // Enter key
    }
    
    static func sendTab() {
        sendKeyEvent(keyCode: 48, modifiers: []) // Tab key
    }
    
    static func sendEscape() {
        sendKeyEvent(keyCode: 53, modifiers: []) // Escape key
    }
    
    // MARK: - Clipboard Operations
    
    static func typeTextViaClipboard(_ text: String) {
        print("📋 Typing text via clipboard: \(text)")
        
        // Save current clipboard content
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
        
        // Set new content to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Send Command+V to paste
        sendKeyEvent(keyCode: 9, modifiers: [.command]) // V key with Command
        
        // Restore original clipboard content after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pasteboard.clearContents()
            if let original = originalContent {
                pasteboard.setString(original, forType: .string)
            }
        }
    }
    
    // MARK: - Advanced Key Combinations
    
    static func sendFormattingShortcut(_ shortcut: FormattingShortcut) {
        let (keyCode, modifiers) = shortcut.keyCodeAndModifiers
        sendKeyEvent(keyCode: keyCode, modifiers: modifiers)
    }
    
    enum FormattingShortcut {
        case bold           // Command+B
        case italic         // Command+I
        case underline      // Command+U
        case title          // Command+Shift+T
        case heading        // Command+Shift+H
        case subheading     // Command+Shift+J
        case body           // Command+Shift+B
        case checklist      // Command+Shift+U
        case bulletedList   // Command+Shift+8
        case numberedList   // Command+Shift+7
        case monostyled     // Command+Shift+M
        
        var keyCodeAndModifiers: (UInt16, NSEvent.ModifierFlags) {
            switch self {
            case .bold:
                return (11, [.command])         // B
            case .italic:
                return (34, [.command])         // I
            case .underline:
                return (32, [.command])         // U
            case .title:
                return (17, [.command, .shift]) // T
            case .heading:
                return (4, [.command, .shift])  // H
            case .subheading:
                return (38, [.command, .shift]) // J
            case .body:
                return (11, [.command, .shift]) // B
            case .checklist:
                return (32, [.command, .shift]) // U
            case .bulletedList:
                return (28, [.command, .shift]) // 8
            case .numberedList:
                return (26, [.command, .shift]) // 7
            case .monostyled:
                return (46, [.command, .shift]) // M
            }
        }
    }
}
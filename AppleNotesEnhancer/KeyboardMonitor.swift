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
    
    func start() -> Bool {
        guard !isMonitoring else { return true }
        
        print("⌨️ Starting keyboard monitoring...")
        
        // Try to set up global event monitoring with error handling
        do {
            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                self?.handleKeyEventSafely(event)
            }
            
            // Set up local event monitoring
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                self?.handleKeyEventSafely(event)
                return event // Pass through the event
            }
            
            if globalMonitor != nil {
                isMonitoring = true
                print("✅ Keyboard monitoring started successfully")
                return true
            } else {
                print("⚠️ Global monitoring not available (permissions needed)")
                return false
            }
        } catch {
            print("❌ Failed to start keyboard monitoring: \(error)")
            return false
        }
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
    
    private func handleKeyEventSafely(_ event: NSEvent) {
        guard isMonitoring else { return }
        
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags
        
        // Call the callback safely
        DispatchQueue.main.async { [weak self] in
            self?.onKeyPressed?(keyCode, modifiers)
        }
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
            
            // Arrow keys
            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        
        return keyCodeMap[keyCode]
    }
    
    // MARK: - Safe Event Injection
    
    static func sendKeyEventSafely(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        // Only send events if we can do so safely
        guard AXIsProcessTrusted() else {
            print("⚠️ Cannot send key events - accessibility permission needed")
            return
        }
        
        // Convert NSEvent modifiers to CGEvent flags
        var cgFlags: CGEventFlags = []
        
        if modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
        if modifiers.contains(.shift) { cgFlags.insert(.maskShift) }
        if modifiers.contains(.option) { cgFlags.insert(.maskAlternate) }
        if modifiers.contains(.control) { cgFlags.insert(.maskControl) }
        
        // Create and send key events with error handling
        autoreleasepool {
            // Create key down event
            if let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) {
                keyDownEvent.flags = cgFlags
                keyDownEvent.post(tap: .cghidEventTap)
                
                // Small delay
                usleep(5000) // 5ms
                
                // Create key up event
                if let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false) {
                    keyUpEvent.flags = cgFlags
                    keyUpEvent.post(tap: .cghidEventTap)
                }
            }
        }
    }
    
    // MARK: - Safe Clipboard Operations
    
    static func typeTextViaClipboardSafely(_ text: String) {
        guard !text.isEmpty else { return }
        
        print("📋 Typing text via clipboard: \(text.prefix(20))...")
        
        // Save current clipboard content
        let pasteboard = NSPasteboard.general
        let originalTypes = pasteboard.types ?? []
        var originalContent: [NSPasteboard.PasteboardType: Any] = [:]
        
        // Save original clipboard data
        for type in originalTypes {
            if let data = pasteboard.data(forType: type) {
                originalContent[type] = data
            } else if let string = pasteboard.string(forType: type) {
                originalContent[type] = string
            }
        }
        
        // Set new content to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Send Command+V to paste
        sendKeyEventSafely(keyCode: 9, modifiers: [.command]) // V key with Command
        
        // Restore original clipboard content after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            pasteboard.clearContents()
            
            // Restore original data
            for (type, content) in originalContent {
                if let data = content as? Data {
                    pasteboard.setData(data, forType: type)
                } else if let string = content as? String {
                    pasteboard.setString(string, forType: type)
                }
            }
        }
    }
    
    // MARK: - Safe Special Key Methods
    
    static func sendBackspaceSafely(count: Int = 1) {
        guard count > 0 else { return }
        
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                sendKeyEventSafely(keyCode: 51, modifiers: []) // Backspace key
            }
        }
    }
    
    static func sendEnterSafely() {
        sendKeyEventSafely(keyCode: 36, modifiers: []) // Enter key
    }
    
    static func sendTabSafely() {
        sendKeyEventSafely(keyCode: 48, modifiers: []) // Tab key
    }
    
    static func sendEscapeSafely() {
        sendKeyEventSafely(keyCode: 53, modifiers: []) // Escape key
    }
    
    // MARK: - Safe Advanced Key Combinations
    
    static func sendFormattingShortcutSafely(_ shortcut: FormattingShortcut) {
        let (keyCode, modifiers) = shortcut.keyCodeAndModifiers
        sendKeyEventSafely(keyCode: keyCode, modifiers: modifiers)
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
    
    // MARK: - Legacy Methods (Deprecated but kept for compatibility)
    
    static func sendKeyEvent(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        sendKeyEventSafely(keyCode: keyCode, modifiers: modifiers)
    }
    
    static func typeTextViaClipboard(_ text: String) {
        typeTextViaClipboardSafely(text)
    }
    
    static func sendFormattingShortcut(_ shortcut: FormattingShortcut) {
        sendFormattingShortcutSafely(shortcut)
    }
}
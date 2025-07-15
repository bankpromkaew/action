import Cocoa
import ApplicationServices

class AccessibilityManager {
    
    private var notesApp: AXUIElement?
    private var currentWindow: AXUIElement?
    private var currentTextArea: AXUIElement?
    
    // MARK: - Initialization
    
    init() {
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        print("🔧 Setting up accessibility manager...")
        
        // Check if accessibility is enabled
        guard AXIsProcessTrusted() else {
            print("❌ Accessibility not enabled")
            return
        }
        
        print("✅ Accessibility enabled")
        findNotesApp()
    }
    
    // MARK: - App Discovery
    
    private func findNotesApp() {
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            if app.bundleIdentifier == "com.apple.Notes" {
                print("📝 Found Notes app with PID: \(app.processIdentifier)")
                notesApp = AXUIElementCreateApplication(app.processIdentifier)
                break
            }
        }
        
        if notesApp == nil {
            print("⚠️ Notes app not found - will retry when Notes is launched")
        }
    }
    
    func refreshNotesConnection() {
        findNotesApp()
        if notesApp != nil {
            updateCurrentWindow()
        }
    }
    
    // MARK: - Window Management
    
    private func updateCurrentWindow() {
        guard let notesApp = notesApp else { return }
        
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(notesApp, kAXWindowsAttribute as CFString, &windowsRef)
        
        guard result == .success,
              let windows = windowsRef as? [AXUIElement],
              let frontWindow = windows.first else {
            print("⚠️ Could not get Notes windows")
            return
        }
        
        currentWindow = frontWindow
        print("🪟 Updated current Notes window")
        
        findTextArea()
    }
    
    private func findTextArea() {
        guard let window = currentWindow else { return }
        
        // Find the main text area in the Notes window
        if let textArea = findElementRecursively(window, role: kAXTextAreaRole) {
            currentTextArea = textArea
            print("📝 Found Notes text area")
        } else {
            print("⚠️ Could not find Notes text area")
        }
    }
    
    // MARK: - Element Discovery
    
    private func findElementRecursively(_ element: AXUIElement, role: String) -> AXUIElement? {
        // Check if this element has the desired role
        var roleRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef) == .success,
           let elementRole = roleRef as? String,
           elementRole == role {
            return element
        }
        
        // Search children
        var childrenRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef) == .success,
           let children = childrenRef as? [AXUIElement] {
            
            for child in children {
                if let found = findElementRecursively(child, role: role) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Text Operations
    
    func getCurrentText() -> String? {
        guard let textArea = currentTextArea else {
            updateCurrentWindow()
            guard let textArea = currentTextArea else { return nil }
        }
        
        var valueRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(textArea, kAXValueAttribute as CFString, &valueRef)
        
        guard result == .success, let text = valueRef as? String else {
            print("⚠️ Could not get current text")
            return nil
        }
        
        return text
    }
    
    func getSelectedText() -> String? {
        guard let textArea = currentTextArea else { return nil }
        
        var selectedTextRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(textArea, kAXSelectedTextAttribute as CFString, &selectedTextRef)
        
        guard result == .success, let selectedText = selectedTextRef as? String else {
            return nil
        }
        
        return selectedText
    }
    
    func getSelectionRange() -> NSRange? {
        guard let textArea = currentTextArea else { return nil }
        
        var selectedRangeRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(textArea, kAXSelectedTextRangeAttribute as CFString, &selectedRangeRef)
        
        guard result == .success, let selectedRange = selectedRangeRef as? AXValue else {
            return nil
        }
        
        var range = CFRange()
        if AXValueGetValue(selectedRange, .cfRange, &range) {
            return NSRange(location: range.location, length: range.length)
        }
        
        return nil
    }
    
    func insertText(_ text: String, at position: Int? = nil) -> Bool {
        guard let textArea = currentTextArea else { return false }
        
        if let position = position {
            // Set insertion point
            let cfRange = CFRange(location: position, length: 0)
            if let axValue = AXValueCreate(.cfRange, &cfRange) {
                AXUIElementSetAttributeValue(textArea, kAXSelectedTextRangeAttribute as CFString, axValue)
            }
        }
        
        // Insert text using accessibility
        let result = AXUIElementSetAttributeValue(textArea, kAXSelectedTextAttribute as CFString, text as CFString)
        
        return result == .success
    }
    
    func replaceText(in range: NSRange, with text: String) -> Bool {
        guard let textArea = currentTextArea else { return false }
        
        // Set selection to the range we want to replace
        let cfRange = CFRange(location: range.location, length: range.length)
        if let axValue = AXValueCreate(.cfRange, &cfRange) {
            let setResult = AXUIElementSetAttributeValue(textArea, kAXSelectedTextRangeAttribute as CFString, axValue)
            guard setResult == .success else { return false }
        }
        
        // Replace selected text
        let replaceResult = AXUIElementSetAttributeValue(textArea, kAXSelectedTextAttribute as CFString, text as CFString)
        
        return replaceResult == .success
    }
    
    // MARK: - Cursor Management
    
    func getCursorPosition() -> Int? {
        guard let range = getSelectionRange() else { return nil }
        return range.location
    }
    
    func setCursorPosition(_ position: Int) -> Bool {
        guard let textArea = currentTextArea else { return false }
        
        let cfRange = CFRange(location: position, length: 0)
        guard let axValue = AXValueCreate(.cfRange, &cfRange) else { return false }
        
        let result = AXUIElementSetAttributeValue(textArea, kAXSelectedTextRangeAttribute as CFString, axValue)
        return result == .success
    }
    
    // MARK: - Formatting Detection
    
    func getCurrentLineText() -> String? {
        guard let fullText = getCurrentText(),
              let cursorPosition = getCursorPosition() else { return nil }
        
        let nsString = fullText as NSString
        let lineRange = nsString.lineRange(for: NSRange(location: cursorPosition, length: 0))
        
        return nsString.substring(with: lineRange)
    }
    
    func getTextBeforeCursor(maxLength: Int = 50) -> String? {
        guard let fullText = getCurrentText(),
              let cursorPosition = getCursorPosition() else { return nil }
        
        let startPosition = max(0, cursorPosition - maxLength)
        let length = cursorPosition - startPosition
        
        if length > 0 {
            let nsString = fullText as NSString
            return nsString.substring(with: NSRange(location: startPosition, length: length))
        }
        
        return nil
    }
    
    // MARK: - Utility Methods
    
    func isNotesActive() -> Bool {
        let frontApp = NSWorkspace.shared.frontmostApplication
        return frontApp?.bundleIdentifier == "com.apple.Notes"
    }
    
    func bringNotesToFront() {
        guard let app = NSWorkspace.shared.runningApplications.first(where: { 
            $0.bundleIdentifier == "com.apple.Notes" 
        }) else {
            // Launch Notes if not running
            NSWorkspace.shared.launchApplication("Notes")
            return
        }
        
        app.activate(options: [.activateIgnoringOtherApps])
    }
    
    // MARK: - Debugging
    
    func printElementHierarchy() {
        guard let window = currentWindow else {
            print("❌ No current window to inspect")
            return
        }
        
        print("🔍 Notes Window Hierarchy:")
        printElementRecursively(window, level: 0)
    }
    
    private func printElementRecursively(_ element: AXUIElement, level: Int) {
        let indent = String(repeating: "  ", count: level)
        
        // Get element properties
        var roleRef: CFTypeRef?
        var titleRef: CFTypeRef?
        var descRef: CFTypeRef?
        
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef)
        AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &descRef)
        
        let role = roleRef as? String ?? "Unknown"
        let title = titleRef as? String
        let description = descRef as? String
        
        var info = "\(indent)- \(role)"
        if let title = title, !title.isEmpty {
            info += " '\(title)'"
        }
        if let description = description, !description.isEmpty {
            info += " (\(description))"
        }
        
        print(info)
        
        // Print children (limit depth to avoid infinite recursion)
        if level < 5 {
            var childrenRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef) == .success,
               let children = childrenRef as? [AXUIElement] {
                
                for child in children {
                    printElementRecursively(child, level: level + 1)
                }
            }
        }
    }
}
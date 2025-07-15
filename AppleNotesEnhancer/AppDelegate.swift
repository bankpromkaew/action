import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var notesEnhancer: NotesEnhancer?
    private var statusItem: NSStatusItem?
    private var permissionCheckTimer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 Apple Notes Enhancer starting...")
        
        // Create status bar item first
        setupStatusBar()
        
        // Start with a delay to avoid blocking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.initializeEnhancer()
        }
    }
    
    private func initializeEnhancer() {
        // Check permissions gracefully
        if checkPermissionsGracefully() {
            // Initialize the notes enhancer
            notesEnhancer = NotesEnhancer()
            notesEnhancer?.start()
            updateStatusMenu(isWorking: true)
            print("✅ Apple Notes Enhancer initialized successfully!")
        } else {
            // Set up timer to check permissions periodically
            setupPermissionCheckTimer()
            updateStatusMenu(isWorking: false)
            print("⚠️ Waiting for permissions...")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        permissionCheckTimer?.invalidate()
        notesEnhancer?.stop()
        print("👋 Apple Notes Enhancer shutting down...")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in background
    }
    
    // MARK: - Status Bar
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Notes Enhancer")
            button.toolTip = "Apple Notes Enhancer"
        }
        
        updateStatusMenu(isWorking: false)
    }
    
    private func updateStatusMenu(isWorking: Bool) {
        let menu = NSMenu()
        
        if isWorking {
            menu.addItem(NSMenuItem(title: "✅ Status: Active", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Features: Markdown, Slash Commands, ⌘P", action: nil, keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "⚠️ Status: Needs Permissions", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Click 'Setup Permissions' below", action: nil, keyEquivalent: ""))
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Apple Notes", action: #selector(openNotes), keyEquivalent: "n"))
        
        let permissionItem = NSMenuItem(title: "Setup Permissions", action: #selector(setupPermissions), keyEquivalent: "")
        menu.addItem(permissionItem)
        
        menu.addItem(NSMenuItem(title: "Test Features", action: #selector(showFeatureDemo), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func openNotes() {
        if let notesApp = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Notes") {
            NSWorkspace.shared.openApplication(at: notesApp, configuration: NSWorkspace.OpenConfiguration())
        } else {
            // Fallback
            NSWorkspace.shared.launchApplication("Notes")
        }
    }
    
    @objc private func setupPermissions() {
        showPermissionGuide()
    }
    
    @objc private func showFeatureDemo() {
        showFeatureGuide()
    }
    
    // MARK: - Permission Handling
    
    private func checkPermissionsGracefully() -> Bool {
        // Check accessibility permission
        let accessibilityEnabled = AXIsProcessTrusted()
        
        // Check input monitoring more safely
        let inputMonitoringEnabled = checkInputMonitoringGracefully()
        
        print("📋 Permission Status:")
        print("   Accessibility: \(accessibilityEnabled ? "✅" : "❌")")
        print("   Input Monitoring: \(inputMonitoringEnabled ? "✅" : "❌")")
        
        return accessibilityEnabled && inputMonitoringEnabled
    }
    
    private func checkInputMonitoringGracefully() -> Bool {
        // Try to check input monitoring without triggering system dialogs
        let eventMask: NSEvent.EventTypeMask = [.keyDown]
        var hasPermission = false
        
        // Create a very brief monitor to test permission
        if let monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask, handler: { _ in }) {
            hasPermission = true
            NSEvent.removeMonitor(monitor)
        }
        
        return hasPermission
    }
    
    private func setupPermissionCheckTimer() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            if self?.checkPermissionsGracefully() == true {
                self?.permissionCheckTimer?.invalidate()
                self?.initializeEnhancer()
            }
        }
    }
    
    private func showPermissionGuide() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Setup Apple Notes Enhancer"
            alert.informativeText = """
            To enable all features, please grant these permissions:
            
            1. ACCESSIBILITY:
               • System Preferences → Security & Privacy → Privacy → Accessibility
               • Click the lock and enter your password
               • Check "Apple Notes Enhancer"
            
            2. INPUT MONITORING:
               • System Preferences → Security & Privacy → Privacy → Input Monitoring  
               • Click the lock and enter your password
               • Check "Apple Notes Enhancer"
            
            The app will detect when permissions are granted and start working automatically.
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "I'll Do It Later")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Open System Preferences to Privacy settings
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    private func showFeatureGuide() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Apple Notes Enhancer Features"
            alert.informativeText = """
            Once permissions are granted, try these features in Apple Notes:
            
            📝 MARKDOWN SHORTCUTS:
            • Type "# " → becomes a title
            • Type "## " → becomes a heading
            • Type "- " → becomes a bullet list
            • Type "> " → becomes a blockquote
            • Type "[] " → becomes a checklist
            
            ⚡ SLASH COMMANDS:
            • Type "/heading " → format as heading
            • Type "/checklist " → create checklist
            • Type "/table " → insert table
            
            🎯 COMMAND PALETTE:
            • Press ⌘P in Notes → search commands
            
            The app only works when Apple Notes is the active application.
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Got It!")
            alert.runModal()
        }
    }
}
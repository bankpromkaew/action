import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var notesEnhancer: NotesEnhancer?
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 Apple Notes Enhancer starting...")
        
        // Create status bar item
        setupStatusBar()
        
        // Check permissions
        checkPermissions()
        
        // Initialize the notes enhancer
        notesEnhancer = NotesEnhancer()
        notesEnhancer?.start()
        
        print("✅ Apple Notes Enhancer initialized successfully!")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
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
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Status: Active", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Apple Notes", action: #selector(openNotes), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Check Permissions", action: #selector(checkPermissionsAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func openNotes() {
        NSWorkspace.shared.launchApplication("Notes")
    }
    
    @objc private func checkPermissionsAction() {
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    private func checkPermissions() {
        let accessibilityEnabled = AXIsProcessTrusted()
        let inputMonitoringEnabled = checkInputMonitoringPermission()
        
        print("📋 Permission Status:")
        print("   Accessibility: \(accessibilityEnabled ? "✅" : "❌")")
        print("   Input Monitoring: \(inputMonitoringEnabled ? "✅" : "❌")")
        
        if !accessibilityEnabled {
            showPermissionAlert(
                title: "Accessibility Permission Required",
                message: "Apple Notes Enhancer needs Accessibility permission to enhance your Notes experience.\n\nGo to System Preferences > Security & Privacy > Privacy > Accessibility and enable 'Apple Notes Enhancer'."
            )
        }
        
        if !inputMonitoringEnabled {
            showPermissionAlert(
                title: "Input Monitoring Permission Required",
                message: "Apple Notes Enhancer needs Input Monitoring permission to detect keyboard shortcuts.\n\nGo to System Preferences > Security & Privacy > Privacy > Input Monitoring and enable 'Apple Notes Enhancer'."
            )
        }
    }
    
    private func checkInputMonitoringPermission() -> Bool {
        // Try to create a global event monitor to test permissions
        let eventMask = NSEvent.EventTypeMask.keyDown
        let monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { _ in }
        
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            return true
        }
        return false
    }
    
    private func showPermissionAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Later")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }
}
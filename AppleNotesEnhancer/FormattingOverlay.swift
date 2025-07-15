import Cocoa

class FormattingOverlay {
    
    private var commandPaletteWindow: NSWindow?
    private var isVisible = false
    
    // MARK: - Initialization
    
    init() {
        setupCommandPalette()
    }
    
    // MARK: - Command Palette
    
    private func setupCommandPalette() {
        let windowFrame = NSRect(x: 0, y: 0, width: 400, height: 250)
        
        commandPaletteWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        guard let window = commandPaletteWindow else { return }
        
        // Configure window properties
        window.level = NSWindow.Level.floating
        window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        window.hasShadow = true
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Create content view
        let contentView = SimpleCommandPaletteView()
        contentView.onCommandSelected = { [weak self] command in
            self?.handleCommand(command)
        }
        contentView.onDismiss = { [weak self] in
            self?.hideCommandPalette()
        }
        
        window.contentView = contentView
        
        // Add border
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 8
        contentView.layer?.borderWidth = 1
        contentView.layer?.borderColor = NSColor.separatorColor.cgColor
        contentView.layer?.masksToBounds = true
    }
    
    private func handleCommand(_ command: String) {
        print("⚡ Executing command: \(command)")
        
        switch command {
        case "Title":
            KeyboardMonitor.sendFormattingShortcutSafely(.title)
        case "Heading":
            KeyboardMonitor.sendFormattingShortcutSafely(.heading)
        case "Subheading":
            KeyboardMonitor.sendFormattingShortcutSafely(.subheading)
        case "Body":
            KeyboardMonitor.sendFormattingShortcutSafely(.body)
        case "Checklist":
            KeyboardMonitor.sendFormattingShortcutSafely(.checklist)
        case "Bulleted List":
            KeyboardMonitor.sendFormattingShortcutSafely(.bulletedList)
        case "Numbered List":
            KeyboardMonitor.sendFormattingShortcutSafely(.numberedList)
        case "Code":
            KeyboardMonitor.sendFormattingShortcutSafely(.monostyled)
        case "Table":
            insertTable()
        case "Bold":
            KeyboardMonitor.sendFormattingShortcutSafely(.bold)
        case "Italic":
            KeyboardMonitor.sendFormattingShortcutSafely(.italic)
        default:
            break
        }
        
        hideCommandPalette()
    }
    
    private func insertTable() {
        let tableText = """
        
        | Header 1 | Header 2 | Header 3 |
        |----------|----------|----------|
        | Cell 1   | Cell 2   | Cell 3   |
        
        """
        KeyboardMonitor.typeTextViaClipboardSafely(tableText)
    }
    
    // MARK: - Public Interface
    
    func showCommandPalette() {
        guard let window = commandPaletteWindow else { return }
        
        // Center on screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = NSRect(
                x: screenFrame.midX - 200,
                y: screenFrame.midY - 125,
                width: 400,
                height: 250
            )
            
            window.setFrame(windowFrame, display: true)
        }
        
        window.orderFront(nil)
        window.makeKey()
        
        // Focus on search field
        if let contentView = window.contentView as? SimpleCommandPaletteView {
            contentView.focusSearchField()
        }
        
        print("🎯 Showing command palette")
    }
    
    func hideCommandPalette() {
        commandPaletteWindow?.orderOut(nil)
        print("🎯 Hiding command palette")
    }
    
    func hide() {
        hideCommandPalette()
    }
    
    // For backwards compatibility
    func showFormattingBar(at point: NSPoint? = nil) {
        showCommandPalette()
    }
    
    func hideFormattingBar() {
        hideCommandPalette()
    }
}

// MARK: - Simple Command Palette View

class SimpleCommandPaletteView: NSView, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    var onCommandSelected: ((String) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var searchField: NSTextField!
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    
    private let allCommands = [
        "Title", "Heading", "Subheading", "Body",
        "Checklist", "Bulleted List", "Numbered List",
        "Code", "Table", "Bold", "Italic"
    ]
    
    private var filteredCommands: [String] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        wantsLayer = true
        filteredCommands = allCommands
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "⌘ Command Palette")
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = NSColor.labelColor
        
        // Search field
        searchField = NSTextField()
        searchField.placeholderString = "Search commands..."
        searchField.delegate = self
        searchField.font = NSFont.systemFont(ofSize: 13)
        
        // Table view
        tableView = NSTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerView = nil
        tableView.intercellSpacing = NSSize(width: 0, height: 2)
        tableView.backgroundColor = NSColor.clear
        tableView.selectionHighlightStyle = .regular
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("command"))
        column.title = "Command"
        tableView.addTableColumn(column)
        
        // Scroll view
        scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = NSColor.clear
        
        // Layout
        addSubview(titleLabel)
        addSubview(searchField)
        addSubview(scrollView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 22),
            
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        // Select first item by default
        DispatchQueue.main.async {
            if self.filteredCommands.count > 0 {
                self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
        }
    }
    
    func focusSearchField() {
        DispatchQueue.main.async {
            self.window?.makeFirstResponder(self.searchField)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36: // Enter
            executeSelectedCommand()
        case 53: // Escape
            onDismiss?()
        case 125: // Down arrow
            moveSelection(down: true)
        case 126: // Up arrow
            moveSelection(down: false)
        default:
            super.keyDown(with: event)
        }
    }
    
    private func executeSelectedCommand() {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 && selectedRow < filteredCommands.count {
            let command = filteredCommands[selectedRow]
            onCommandSelected?(command)
        }
    }
    
    private func moveSelection(down: Bool) {
        let currentRow = tableView.selectedRow
        let newRow: Int
        
        if down {
            newRow = min(currentRow + 1, filteredCommands.count - 1)
        } else {
            newRow = max(currentRow - 1, 0)
        }
        
        tableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
        tableView.scrollRowToVisible(newRow)
    }
    
    // MARK: - NSTextFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        let searchText = searchField.stringValue.lowercased()
        
        if searchText.isEmpty {
            filteredCommands = allCommands
        } else {
            filteredCommands = allCommands.filter { command in
                command.lowercased().contains(searchText)
            }
        }
        
        tableView.reloadData()
        
        // Select first item
        if filteredCommands.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredCommands.count
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = NSTableCellView()
        
        let textField = NSTextField()
        textField.stringValue = filteredCommands[row]
        textField.isBordered = false
        textField.backgroundColor = NSColor.clear
        textField.isEditable = false
        textField.font = NSFont.systemFont(ofSize: 12)
        
        cellView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 6),
            textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -6),
            textField.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
        
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Handle selection change if needed
    }
}
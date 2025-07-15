import Cocoa

class FormattingOverlay {
    
    private var formattingWindow: NSWindow?
    private var commandPaletteWindow: NSWindow?
    private var isVisible = false
    
    // MARK: - Initialization
    
    init() {
        setupFormattingBar()
        setupCommandPalette()
    }
    
    // MARK: - Formatting Bar
    
    private func setupFormattingBar() {
        let windowFrame = NSRect(x: 0, y: 0, width: 400, height: 60)
        
        formattingWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        guard let window = formattingWindow else { return }
        
        // Configure window properties
        window.level = NSWindow.Level.floating
        window.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95)
        window.hasShadow = true
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Create content view
        let contentView = FormattingBarView()
        contentView.onButtonPressed = { [weak self] action in
            self?.handleFormattingAction(action)
        }
        
        window.contentView = contentView
        
        // Add visual effects
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        
        contentView.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer?.cornerRadius = 8
        contentView.layer?.masksToBounds = true
    }
    
    private func handleFormattingAction(_ action: FormattingAction) {
        print("🎨 Handling formatting action: \(action)")
        
        switch action {
        case .bold:
            KeyboardMonitor.sendFormattingShortcut(.bold)
        case .italic:
            KeyboardMonitor.sendFormattingShortcut(.italic)
        case .underline:
            KeyboardMonitor.sendFormattingShortcut(.underline)
        case .title:
            KeyboardMonitor.sendFormattingShortcut(.title)
        case .heading:
            KeyboardMonitor.sendFormattingShortcut(.heading)
        case .subheading:
            KeyboardMonitor.sendFormattingShortcut(.subheading)
        case .body:
            KeyboardMonitor.sendFormattingShortcut(.body)
        case .checklist:
            KeyboardMonitor.sendFormattingShortcut(.checklist)
        case .bulletedList:
            KeyboardMonitor.sendFormattingShortcut(.bulletedList)
        case .numberedList:
            KeyboardMonitor.sendFormattingShortcut(.numberedList)
        case .monostyled:
            KeyboardMonitor.sendFormattingShortcut(.monostyled)
        case .insertLink:
            insertLink()
        case .insertTable:
            insertTable()
        }
        
        // Hide formatting bar after use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideFormattingBar()
        }
    }
    
    private func insertLink() {
        let linkText = "[Link Text](https://example.com)"
        KeyboardMonitor.typeTextViaClipboard(linkText)
    }
    
    private func insertTable() {
        let tableText = """
        
        | Column 1 | Column 2 | Column 3 |
        |----------|----------|----------|
        |          |          |          |
        |          |          |          |
        
        """
        KeyboardMonitor.typeTextViaClipboard(tableText)
    }
    
    // MARK: - Command Palette
    
    private func setupCommandPalette() {
        let windowFrame = NSRect(x: 0, y: 0, width: 500, height: 300)
        
        commandPaletteWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        guard let window = commandPaletteWindow else { return }
        
        // Configure window properties
        window.level = NSWindow.Level.floating
        window.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95)
        window.hasShadow = true
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Create content view
        let contentView = CommandPaletteView()
        contentView.onCommandSelected = { [weak self] command in
            self?.handleCommand(command)
        }
        contentView.onDismiss = { [weak self] in
            self?.hideCommandPalette()
        }
        
        window.contentView = contentView
        
        // Add visual effects
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        
        contentView.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer?.cornerRadius = 12
        contentView.layer?.masksToBounds = true
    }
    
    private func handleCommand(_ command: String) {
        print("⚡ Executing command: \(command)")
        
        switch command {
        case "Format as Title":
            KeyboardMonitor.sendFormattingShortcut(.title)
        case "Format as Heading":
            KeyboardMonitor.sendFormattingShortcut(.heading)
        case "Format as Subheading":
            KeyboardMonitor.sendFormattingShortcut(.subheading)
        case "Format as Body":
            KeyboardMonitor.sendFormattingShortcut(.body)
        case "Create Checklist":
            KeyboardMonitor.sendFormattingShortcut(.checklist)
        case "Create Bulleted List":
            KeyboardMonitor.sendFormattingShortcut(.bulletedList)
        case "Create Numbered List":
            KeyboardMonitor.sendFormattingShortcut(.numberedList)
        case "Format as Code":
            KeyboardMonitor.sendFormattingShortcut(.monostyled)
        case "Insert Table":
            insertTable()
        case "Insert Link":
            insertLink()
        default:
            break
        }
        
        hideCommandPalette()
    }
    
    // MARK: - Public Interface
    
    func showFormattingBar(at point: NSPoint? = nil) {
        guard let window = formattingWindow else { return }
        
        let targetPoint = point ?? getSelectionPoint()
        
        // Position window near selection or cursor
        let windowFrame = NSRect(
            x: targetPoint.x - 200, // Center horizontally
            y: targetPoint.y + 30,  // Position above selection
            width: 400,
            height: 60
        )
        
        window.setFrame(windowFrame, display: true)
        window.orderFront(nil)
        isVisible = true
        
        print("📊 Showing formatting bar at \(targetPoint)")
        
        // Auto-hide after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.hideFormattingBar()
        }
    }
    
    func hideFormattingBar() {
        formattingWindow?.orderOut(nil)
        isVisible = false
        print("📊 Hiding formatting bar")
    }
    
    func showCommandPalette() {
        guard let window = commandPaletteWindow else { return }
        
        // Center on screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = NSRect(
                x: screenFrame.midX - 250,
                y: screenFrame.midY - 150,
                width: 500,
                height: 300
            )
            
            window.setFrame(windowFrame, display: true)
        }
        
        window.orderFront(nil)
        window.makeKey()
        
        print("🎯 Showing command palette")
    }
    
    func hideCommandPalette() {
        commandPaletteWindow?.orderOut(nil)
        print("🎯 Hiding command palette")
    }
    
    func hide() {
        hideFormattingBar()
        hideCommandPalette()
    }
    
    // MARK: - Utilities
    
    private func getSelectionPoint() -> NSPoint {
        // Try to get cursor position from Notes
        // For now, use mouse location as fallback
        let mouseLocation = NSEvent.mouseLocation
        return NSPoint(x: mouseLocation.x, y: mouseLocation.y)
    }
}

// MARK: - Formatting Actions

enum FormattingAction {
    case bold, italic, underline
    case title, heading, subheading, body
    case checklist, bulletedList, numberedList, monostyled
    case insertLink, insertTable
}

// MARK: - Formatting Bar View

class FormattingBarView: NSView {
    
    var onButtonPressed: ((FormattingAction) -> Void)?
    
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
        
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        // Create formatting buttons
        let buttons: [(String, FormattingAction, String)] = [
            ("B", .bold, "Bold"),
            ("I", .italic, "Italic"),
            ("U", .underline, "Underline"),
            ("T1", .title, "Title"),
            ("T2", .heading, "Heading"),
            ("T3", .subheading, "Subheading"),
            ("●", .bulletedList, "Bulleted List"),
            ("✓", .checklist, "Checklist"),
            ("🔗", .insertLink, "Insert Link"),
            ("⊞", .insertTable, "Insert Table")
        ]
        
        for (title, action, tooltip) in buttons {
            let button = NSButton()
            button.title = title
            button.bezelStyle = .rounded
            button.toolTip = tooltip
            button.target = self
            button.action = #selector(buttonPressed(_:))
            button.tag = action.rawValue
            
            // Style the button
            button.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)
        ])
    }
    
    @objc private func buttonPressed(_ sender: NSButton) {
        if let action = FormattingAction(rawValue: sender.tag) {
            onButtonPressed?(action)
        }
    }
}

// MARK: - Command Palette View

class CommandPaletteView: NSView, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    var onCommandSelected: ((String) -> Void)?
    var onDismiss: (() -> Void)?
    
    private var searchField: NSTextField!
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    
    private let allCommands = [
        "Format as Title",
        "Format as Heading", 
        "Format as Subheading",
        "Format as Body",
        "Create Checklist",
        "Create Bulleted List",
        "Create Numbered List",
        "Format as Code",
        "Insert Table",
        "Insert Link",
        "Bold Text",
        "Italic Text",
        "Underline Text"
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
        
        // Search field
        searchField = NSTextField()
        searchField.placeholderString = "Type to search commands..."
        searchField.delegate = self
        searchField.font = NSFont.systemFont(ofSize: 14)
        
        // Table view
        tableView = NSTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerView = nil
        tableView.intercellSpacing = NSSize(width: 0, height: 4)
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
        addSubview(searchField)
        addSubview(scrollView)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 24),
            
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
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
        textField.font = NSFont.systemFont(ofSize: 13)
        
        cellView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
        
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Visual feedback could go here
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

// MARK: - FormattingAction Extension

extension FormattingAction {
    var rawValue: Int {
        switch self {
        case .bold: return 0
        case .italic: return 1
        case .underline: return 2
        case .title: return 3
        case .heading: return 4
        case .subheading: return 5
        case .body: return 6
        case .checklist: return 7
        case .bulletedList: return 8
        case .numberedList: return 9
        case .monostyled: return 10
        case .insertLink: return 11
        case .insertTable: return 12
        }
    }
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .bold
        case 1: self = .italic
        case 2: self = .underline
        case 3: self = .title
        case 4: self = .heading
        case 5: self = .subheading
        case 6: self = .body
        case 7: self = .checklist
        case 8: self = .bulletedList
        case 9: self = .numberedList
        case 10: self = .monostyled
        case 11: self = .insertLink
        case 12: self = .insertTable
        default: return nil
        }
    }
}
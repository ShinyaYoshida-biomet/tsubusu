import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var windowCounter = 1
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    super.applicationDidFinishLaunching(aNotification)
    setupMenuBar()
  }
  
  override func applicationWillFinishLaunching(_ notification: Notification) {
    super.applicationWillFinishLaunching(notification)
    setupMenuBar()
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  private func setupMenuBar() {
    let mainMenu = NSMenu()
    
    // App Menu (first menu item is always the app menu on macOS)
    let appMenuItem = NSMenuItem()
    let appMenu = NSMenu()
    appMenu.addItem(withTitle: "About Tsubusu", action: #selector(showAbout), keyEquivalent: "")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Hide Tsubusu", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h").keyEquivalentModifierMask = [.command, .option]
    appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Quit Tsubusu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    appMenuItem.submenu = appMenu
    mainMenu.addItem(appMenuItem)
    
    // File Menu
    let fileMenuItem = NSMenuItem()
    fileMenuItem.title = "File"
    let fileMenu = NSMenu(title: "File")
    
    let newWindowItem = NSMenuItem(title: "New Window", action: #selector(newWindow), keyEquivalent: "n")
    newWindowItem.target = self
    fileMenu.addItem(newWindowItem)
    
    fileMenu.addItem(NSMenuItem.separator())
    fileMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
    
    fileMenuItem.submenu = fileMenu
    mainMenu.addItem(fileMenuItem)
    
    // Edit Menu (commonly expected in macOS apps)
    let editMenuItem = NSMenuItem()
    editMenuItem.title = "Edit"
    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
    editMenu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
    editMenu.addItem(NSMenuItem.separator())
    editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
    editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
    editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
    editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
    
    editMenuItem.submenu = editMenu
    mainMenu.addItem(editMenuItem)
    
    // View Menu
    let viewMenuItem = NSMenuItem()
    viewMenuItem.title = "View"
    let viewMenu = NSMenu(title: "View")
    viewMenu.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f").keyEquivalentModifierMask = [.command, .control]
    
    viewMenuItem.submenu = viewMenu
    mainMenu.addItem(viewMenuItem)
    
    // Window Menu
    let windowMenuItem = NSMenuItem()
    windowMenuItem.title = "Window"
    let windowMenu = NSMenu(title: "Window")
    windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
    windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
    windowMenu.addItem(NSMenuItem.separator())
    windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
    
    windowMenuItem.submenu = windowMenu
    mainMenu.addItem(windowMenuItem)
    
    // Help Menu
    let helpMenuItem = NSMenuItem()
    helpMenuItem.title = "Help"
    let helpMenu = NSMenu(title: "Help")
    helpMenu.addItem(withTitle: "Tsubusu Help", action: #selector(showHelp), keyEquivalent: "?")
    
    helpMenuItem.submenu = helpMenu
    mainMenu.addItem(helpMenuItem)
    
    NSApplication.shared.mainMenu = mainMenu
    NSApplication.shared.windowsMenu = windowMenu
    NSApplication.shared.helpMenu = helpMenu
  }
  
  @objc private func showAbout() {
    let alert = NSAlert()
    alert.messageText = "Tsubusu"
    alert.informativeText = "A simple todo app for macOS\n\nVersion 1.0.0"
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  
  @objc private func showHelp() {
    let alert = NSAlert()
    alert.messageText = "Tsubusu Help"
    alert.informativeText = "• Add tasks by typing in the input field\n• Click checkboxes to complete tasks\n• Use File > New Window (⌘N) to open multiple windows\n• Drag the hamburger menu (≡) to reorder tasks"
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  
  @objc private func newWindow() {
    // Increment counter for new window
    windowCounter += 1
    
    // Create new window with proper Flutter setup
    let newWindow = NSWindow(
      contentRect: NSRect(x: 130, y: 130, width: 300, height: 400),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    
    let flutterViewController = FlutterViewController()
    newWindow.contentViewController = flutterViewController
    
    // Configure window with title bar visible and numbered name
    newWindow.titlebarAppearsTransparent = false
    newWindow.titleVisibility = .visible
    newWindow.title = "tsubusu \(windowCounter)"
    newWindow.minSize = NSSize(width: 250, height: 300)
    newWindow.maxSize = NSSize(width: 600, height: 800)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    newWindow.makeKeyAndOrderFront(nil)
  }
}

import Cocoa
import FlutterMacOS

class SubWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // Configure like main window - with title bar
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.styleMask.insert(.titled)
    self.styleMask.insert(.closable)
    self.styleMask.insert(.miniaturizable)
    self.styleMask.insert(.resizable)
    
    // Set window size like Stickies
    self.setContentSize(NSSize(width: 300, height: 400))
    self.minSize = NSSize(width: 250, height: 300)
    self.maxSize = NSSize(width: 600, height: 800)
    
    // Set title
    self.title = "Tsubusu"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
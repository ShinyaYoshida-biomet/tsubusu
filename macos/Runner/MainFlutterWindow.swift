import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // Ensure title bar is visible
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.title = "tsubusu"
    
    // Set window size like Stickies
    self.setContentSize(NSSize(width: 300, height: 400))
    self.minSize = NSSize(width: 250, height: 300)
    self.maxSize = NSSize(width: 600, height: 800)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Setup method channel for window title updates
    setupMethodChannel(for: flutterViewController, window: self)

    super.awakeFromNib()
  }
  
  private func setupMethodChannel(for flutterViewController: FlutterViewController, window: NSWindow) {
    let methodChannel = FlutterMethodChannel(
      name: "tsubusu/window_manager",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
    methodChannel.setMethodCallHandler { [weak window] (call, result) in
      switch call.method {
      case "updateWindowTitle":
        if let args = call.arguments as? [String: Any],
           let title = args["title"] as? String,
           let window = window {
          DispatchQueue.main.async {
            window.title = title
          }
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Title not provided", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

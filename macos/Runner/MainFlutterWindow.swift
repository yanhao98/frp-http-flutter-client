import Cocoa
import FlutterMacOS

// BitsdojoWindow Add Start
import bitsdojo_window_macos
class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME
    // return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
// BitsdojoWindow Add End

// class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // // 设置最小窗口尺寸
    // self.minSize = CGSize(width: 1000, height: 400)

    super.awakeFromNib()
  }
}

import SwiftUI
import AppKit

@main
struct StockMonitorApp: App {
    init() {
        // 设置窗口样式为无标题栏
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 300)
        .defaultPosition(.center)
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("Toggle Always on Top") {
                    toggleWindowTopMost()
                }
                .keyboardShortcut("T", modifiers: [.command, .shift])
            }
        }
        .windowToolbarStyle(.unifiedCompact) // 添加这行
        .onChange(of: NSApplication.shared.windows.first) { window in
            window?.standardWindowButton(.closeButton)?.isHidden = true
            window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window?.standardWindowButton(.zoomButton)?.isHidden = true
            window?.titlebarAppearsTransparent = true
            window?.titleVisibility = .hidden
            window?.styleMask.remove(.titled)
        }
    }
}

extension StockMonitorApp {
    func toggleWindowTopMost() {
        if let window = NSApplication.shared.windows.first {
            let level = window.level
            window.level = level == .normal ? .floating : .normal
        }
    }
}

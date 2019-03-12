//
//  SpfMenuController.swift
//  Spf
//
//  Created by Tanner Christensen on 2/20/19.
//  Copyright © 2019 Tanner Christensen. All rights reserved.
//

import Cocoa

class SpfMenuController: NSObject {
    @IBOutlet weak var spfMenu: NSMenu!
    @IBOutlet weak var clearMenuItem: NSMenuItem!
    var overlayWindow: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var isWindowVisible = false
    
    override func awakeFromNib() {
        
        // Waking up, set status bar icon and menu object
        
        let icon = NSImage(named: "polar-icon")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = spfMenu
        clearMenuItem.isEnabled = false
        
        // Add a listener for screen resolution (and other) changes and resize accordingly
        
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
                                               object: NSApplication.shared,
                                               queue: OperationQueue.main) {
                                                                    notification -> Void in
                                                if(self.isWindowVisible){
                                                    let hugeRect = NSMakeRect(0, 0, 20000, 20000)
                                                    self.overlayWindow.setFrame(hugeRect, display: true, animate: false)
                                                }
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        
        // Quit via status bar menu
        
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func goToAbout(sender: NSMenuItem) {
        
        // About item selected, go to URL in user defined web browser
        
        if(sender.title == "About") {
            if let url = URL(string: "https://github.com/tannerc/spf"), NSWorkspace.shared.open(url) {}
        }
    }
    
    @IBAction func removeOverlay(sender: NSMenuItem) {
        
        // Check if the overlay is visible and if so, remove it
        
        if(isWindowVisible){
            isWindowVisible = false
            overlayWindow.close()
            clearMenuItem.isEnabled = false
            let icon = NSImage(named: "polar-icon")
            statusItem.button?.image = icon
        }
    }
    
    @IBAction func  setOverlay(sender: NSMenuItem) {
        
        // Get the overlay value via menu item tag
        
        let overlayValue = Float(sender.tag)
        
        // Check if window is active, if it is not, initialize it with a huge rect, if it is visible just reset the frame
        
        let screenRect = NSScreen.main?.frame
        
        if((overlayWindow) == nil){
            overlayWindow = NSWindow.init(contentRect: screenRect!, styleMask: .fullScreen, backing: NSWindow.BackingStoreType(rawValue: 2)!, defer: false, screen: NSScreen.main)
        } else {
            overlayWindow.setFrame(screenRect!, display: true, animate: false)
        }
        
        // Reset all window settings to refresh the overlay window view
        
        overlayWindow.isReleasedWhenClosed = false
        overlayWindow.level = .floating
        overlayWindow.animationBehavior = .none
        overlayWindow.alphaValue = 1
        overlayWindow.isOpaque = false
        overlayWindow.ignoresMouseEvents = true
        overlayWindow.makeKeyAndOrderFront(Any?.self)
        clearMenuItem.isEnabled = true
        overlayWindow.backgroundColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(overlayValue*0.01))
        
        isWindowVisible = true
        
        if(overlayValue == 0){
            
            // Test option selected becuase the menu item tag is 0, set window to red
            
            overlayWindow.backgroundColor = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
            
            // Animate out after a few seconds to confirm test successful, then remove overlay window view
            
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 4.5
                overlayWindow.animator().alphaValue = 0.1
            }, completionHandler: {
                    self.removeOverlay(sender: self.clearMenuItem)
                self.isWindowVisible = false
            })
        }
        
//        // Change statusbar icon to active to communicate "this is the reason your screen might look funky"
//
//        let icon = NSImage(named: "active-icon")
//        statusItem.button?.image = icon
    }
}

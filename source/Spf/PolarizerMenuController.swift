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
    
    override func awakeFromNib() {
        
        // Waking up, set status bar icon and menu object
        
        let icon = NSImage(named: "polar-icon")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = spfMenu
        clearMenuItem.isEnabled = false
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func goToAbout(sender: NSMenuItem) {
        if(sender.title == "About") {
            if let url = URL(string: "https://github.com/tannerc/spf"), NSWorkspace.shared.open(url) {}
        }
    }
    
    @IBAction func removeOverlay(sender: NSMenuItem) {
        
        // 1. Check if the overlay is visible and if so, remove it
        
        if((overlayWindow) != nil){
            overlayWindow.close()
            clearMenuItem.isEnabled = false
            let icon = NSImage(named: "polar-icon")
            statusItem.button?.image = icon
        }
    }
    
    @IBAction func  setOverlay(sender: NSMenuItem) {
        let overlayValue = Float(sender.tag)
        let screenRect = NSScreen.main?.frame
        
        // Check if window is active, if it is, initialize it
        
        if((overlayWindow) == nil){
            overlayWindow = NSWindow.init(contentRect: screenRect ?? NSScreen.screens[0].frame, styleMask: .fullScreen, backing: NSWindow.BackingStoreType(rawValue: 2)!, defer: false, screen: NSScreen.main)
        }
        
        // Reset all window settings because why not
        
        overlayWindow.isReleasedWhenClosed = false
        overlayWindow.level = .floating
        overlayWindow.animationBehavior = .none
        overlayWindow.alphaValue = 1
        overlayWindow.isOpaque = false
        overlayWindow.ignoresMouseEvents = true
        overlayWindow.makeKeyAndOrderFront(Any?.self)
        clearMenuItem.isEnabled = true
        overlayWindow.backgroundColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(overlayValue*0.01))
        
        if(overlayValue == 0){
            
            // Test option selected, set window to red
            
            overlayWindow.backgroundColor = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
            
            // Animate out to confirm test successful
            
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 4.5
                overlayWindow.animator().alphaValue = 0.1
            }, completionHandler: {
                    self.removeOverlay(sender: self.clearMenuItem)
            })
        }
        
//        // Change statusbar icon to active to communicate "this is the reason your screen might look funky"
//
//        let icon = NSImage(named: "active-icon")
//        statusItem.button?.image = icon
    }
}

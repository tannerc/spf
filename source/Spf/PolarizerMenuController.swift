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
    var overlays: Array<NSWindow> = []
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var areOverlaysVisible = false
    
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
                                                if(self.areOverlaysVisible){
                                                    let hugeRect = NSMakeRect(0, 0, 20000, 20000)
                                                    for overlay in self.overlays {
                                                        overlay.setFrame(hugeRect, display: true, animate: false)
                                                    }
                                                }
        }
    }
    
    @IBAction func removeOverlay(sender: NSMenuItem) {
        
        // Check if an overlay is visible and if so, remove it
        
        if(areOverlaysVisible){
            for overlay in self.overlays {
                overlay.close()
            }
            overlays.removeAll()
            areOverlaysVisible = false
            clearMenuItem.isEnabled = false
            let icon = NSImage(named: "polar-icon")
            statusItem.button?.image = icon
        }
    }
    
    @IBAction func  setOverlay(sender: NSMenuItem) {
        
        // Get the overlay value via menu item tag
        
        let overlayValue = Float(sender.tag)
        
        if(areOverlaysVisible) {
            
            // Overlays exist, just update them with the new settings (and, if appropriate, screen size)
            
            for overlay in overlays {
                overlay.setFrame(overlay.frame, display: true, animate: false)
                overlay.alphaValue = 1
                overlay.makeKeyAndOrderFront(Any?.self)
                clearMenuItem.isEnabled = true
                overlay.backgroundColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(overlayValue*0.01))
            }
        } else {
            
            // No overlays have been created yet, so let's make some
            
            for screen in NSScreen.screens {
                let screenRect = screen.frame
                let newOverlay = NSWindow.init(contentRect: screenRect, styleMask: .fullSizeContentView, backing: NSWindow.BackingStoreType(rawValue: 2)!, defer: false, screen: NSScreen.main)
                newOverlay.isReleasedWhenClosed = false
                newOverlay.level = .floating
                newOverlay.animationBehavior = .none
                newOverlay.alphaValue = 1
                newOverlay.isOpaque = false
                newOverlay.ignoresMouseEvents = true
                newOverlay.makeKeyAndOrderFront(Any?.self)
                clearMenuItem.isEnabled = true
                newOverlay.backgroundColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(overlayValue*0.01))
                overlays.append(newOverlay)
            }
            
            areOverlaysVisible = true
        }
        
        // Test option is from an menu item with a tag of 0, set window to red and animate out if that has been selected
        
        if(overlayValue == 0){
            for overlay in overlays {
                overlay.backgroundColor = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)

                // Animate out after a few seconds to confirm test successful, then remove overlay window view

                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.duration = 4.5
                    overlay.animator().alphaValue = 0.1
                }, completionHandler: {
                        self.removeOverlay(sender: self.clearMenuItem)
                    self.areOverlaysVisible = false
                })
            }
        }
        
//        // OPTIONAL: Change statusbar icon to active to communicate "this is the reason your screen might look funky"
//
//        let icon = NSImage(named: "active-icon")
//        statusItem.button?.image = icon
    }
    
    @IBAction func goToAbout(sender: NSMenuItem) {
        
        // About item selected, go to URL in user defined web browser
        
        if(sender.title == "Learn more →") {
            if let url = URL(string: "https://github.com/tannerc/spf"), NSWorkspace.shared.open(url) {}
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        
        // Quit via status bar menu
        
        NSApplication.shared.terminate(self)
    }
}

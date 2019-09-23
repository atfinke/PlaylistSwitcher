//
//  AppDelegate.swift
//  FloatingBrowser
//
//  Created by Andrew Finke on 6/10/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties -

    private let authManager = AuthenticationManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handleEvent(_:)),
                                     forEventClass: AEEventClass(kInternetEventClass),
                                     andEventID: AEEventID(kAEGetURL))

        guard let bundleID = Bundle.main.bundleIdentifier else { fatalError() }
        LSSetDefaultHandlerForURLScheme("playlist-switcher" as CFString,
                                        bundleID as CFString)

        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: false]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillResignActive(_ notification: Notification) {
        exit(0)
    }

    // MARK: - Open URL -

    @objc func handleEvent(_ event: NSAppleEventDescriptor) {
        guard let descriptor = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)),
            let stringValue = descriptor.stringValue,
            let components = URLComponents(string: stringValue) else {
                return
        }
        authManager.handleOpenURL(components)
    }
}




//
//  LocalEventManager.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI
import Combine

class LocalEventManager: ObservableObject {

    // MARK: - Types -

    enum EventState {
        case ctrl, enter, esc
    }

    // MARK: - Properties -

    let willChange = PassthroughSubject<LocalEventManager, Never>()
    var eventState: EventState = .ctrl {
        willSet {
            willChange.send(self)
        }
    }

    // MARK: - Initalization -

    init() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            return self.handle(event: $0) ? nil : $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            if $0.modifierFlags.intersection(.deviceIndependentFlagsMask) == .control {
                self.eventState = .ctrl
                return nil
            }
            return $0
        }
    }

    // MARK: - Helpers -

    private func handle(event: NSEvent) -> Bool {
        if event.keyCode == 36 {
            eventState = .enter
        } else if event.keyCode == 53 {
            eventState = .esc
        } else {
            return false
        }
        return true
    }
}

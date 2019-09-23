//
//  PlaylistsModel.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI
import Combine

class PlaylistsModel: ObservableObject {

    // MARK: - Properties -

    let objectWillChange = ObservableObjectPublisher()
    var selectedIndex = -1

    let localEventManager = LocalEventManager()
    var playlists = [Playlist]() {
        willSet {
            objectWillChange.send()
        }
    }

    // MARK: - Initalization -

    init() {
        let _ = localEventManager.willChange
            .debounce(for: .milliseconds(1),
                      scheduler: RunLoop.main)
            .sink { manager in
                if manager.eventState == .ctrl {
                    self.selectedIndex += 1
                    if self.selectedIndex > self.playlists.count - 1 {
                        self.selectedIndex = 0
                    }
                }
                self.updated(selectedIndex: self.selectedIndex)
        }
    }

    // MARK: - Updates -

    func update(image: Image, for playlist: Playlist) {
        guard let index = playlists.firstIndex(of: playlist) else { return }
        playlists[index].image = image
    }

    func updated(selectedIndex: Int) {
        let selectedIndex = min(playlists.count - 1, max(0, selectedIndex))
        (0..<playlists.count).forEach { playlists[$0].isSelected = false }
        playlists[selectedIndex].isSelected = true
    }
}

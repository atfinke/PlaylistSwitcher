//
//  Playlist.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI

struct Playlist: Identifiable, Hashable {

    // MARK: - Properties -

    var id: String { return uri }
    let uri: String
    let name: String
    var image: Image
    var isSelected: Bool = false

    // MARK: - Hashable -

    func hash(into hasher: inout Hasher) {
        uri.hash(into: &hasher)
    }
}

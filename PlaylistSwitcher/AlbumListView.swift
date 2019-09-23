//
//  ContentView.swift
//  FloatingBrowser
//
//  Created by Andrew Finke on 6/10/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI
import Combine

struct AlbumListView : View {
    @EnvironmentObject private var model: PlaylistsModel

    var body: some View {
        return ZStack {
            HStack {
                ForEach(model.playlists) {
                    AlbumView(playlist: $0)
                }
            }
        }.padding()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        AlbumListView()
            .previewLayout(.fixed(width: 500, height: 140))
    }
}
#endif

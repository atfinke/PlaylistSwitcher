//
//  AlbumView.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI

struct AlbumView : View {
    var playlist: Playlist

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 115, height: 115)
                .foregroundColor(.white)
            ZStack(alignment: .bottomLeading) {
                playlist.image
                    .resizable()

                Text(playlist.name)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 14,
                                  design: .rounded))
                    .lineLimit(10)
                    .padding(5)
                    .padding(.leading, 5)
            }
            .frame(width: 110, height: 110)
            .cornerRadius(12)

        }
        .scaleEffect(playlist.isSelected ? 1.1 : 1.0)
        .padding()
        .background(Color(.sRGB,
                          white: 0,
                          opacity: playlist.isSelected ? 0.5 : 0.0))
            .cornerRadius(28)
            .scaleEffect(playlist.isSelected ? 1.1 : 1.0)
            .animation(.interactiveSpring())
    }
}

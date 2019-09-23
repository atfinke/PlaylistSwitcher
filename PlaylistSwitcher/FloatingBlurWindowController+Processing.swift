//
//  FloatingBlurWindowController+Processing.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SwiftUI

extension FloatingBlurWindowController {
    
    func processPlaylists(data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any], let items = json["items"] as? [[String: Any]] else {
            fatalError()
        }

        for item in items.prefix(7) {
            process(playlist: item)
        }
    }

    func process(playlist: [String: Any]) {
        guard let name = playlist["name"] as? String,
            let uri = playlist["uri"] as? String,
            let images = playlist["images"] as? [[String: Any]] else {
                return
        }

        var imageURLString: String?
        if images.count > 1 {
            imageURLString = images[1]["url"] as? String
        } else if images.count == 1 {
            imageURLString = images[0]["url"] as? String
        }
        guard let urlString = imageURLString,
            let imageURL = URL(string: urlString) else { return }

        var playlistModel = Playlist(uri: uri,
                                     name: name,
                                     image: Image(nsImage: NSImage()))
        DispatchQueue.main.async {
            self.model.playlists.append(playlistModel)
        }
        download(imageURL: imageURL, for: playlistModel)
    }

    func download(imageURL: URL, for playlist: Playlist) {
        let imageTask = URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            guard let data = data, let image = NSImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.model.update(image: Image(nsImage: image), for: playlist)
            }
        }
        imageTask.resume()
    }

}

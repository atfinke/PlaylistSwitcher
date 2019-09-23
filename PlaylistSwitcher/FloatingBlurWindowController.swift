//
//  FloatingBlurWindowController.swift
//  PlaylistSwitcher
//
//  Created by Andrew Finke on 7/6/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Cocoa
import SwiftUI

class FloatingBlurWindowController: NSWindowController {

    // MARK: - Properties -

    let model = PlaylistsModel()
    let authManager = AuthenticationManager()

    private let effectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = 32.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - View Life Cycle -

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let window = window, let contentView = window.contentView else { fatalError() }

        window.alphaValue = 0.0
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces
        window.titleVisibility = .hidden
        window.styleMask.remove(.titled)
        window.backgroundColor = .clear
        window.contentView?.addSubview(effectView)

        let _ = model.objectWillChange
            .debounce(for: .milliseconds(1),
                      scheduler: RunLoop.main)
            .sink { model in
                switch self.model.localEventManager.eventState {
                case .enter:
                    self.updateNowPlaying()
                case .esc:
                    exit(0)
                default:
                    break
                }

                // uggg
                if self.model.playlists.count > 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.window?.center()
                        self.window?.alphaValue = 1
                        // uggggggg
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.model.selectedIndex == -1 {
                                self.model.selectedIndex = 0
                                self.model.playlists[0].isSelected = true
                                NSApplication.shared.activate(ignoringOtherApps: true)
                            }
                        }
                    }
                }
        }

        let albumListView = AlbumListView().environmentObject(model)
        let hostingView = NSHostingView(rootView: albumListView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(hostingView)

        let constraints = [
            effectView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            effectView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            effectView.topAnchor
                .constraint(equalTo: contentView.topAnchor),
            effectView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor),
            hostingView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            hostingView.topAnchor
                .constraint(equalTo: contentView.topAnchor),
            hostingView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        fetchPlaylists()
    }

    // MARK: - Helpers -

    func fetchPlaylists() {
        authManager.requestAccessToken { accessToken in
            guard let token = accessToken else { return }

            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.spotify.com"
            components.path = "/v1/me/playlists"

            guard let url = components.url else { fatalError() }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    self.processPlaylists(data: data)
                }
            }
            task.resume()
        }
    }

    func updateNowPlaying() {
        guard let playlist = model.playlists.first(where: { playlist -> Bool in
            return playlist.isSelected
        }) else {
            return
        }

        authManager.requestAccessToken { accessToken in
            guard let token = accessToken else { return }

            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.spotify.com"
            components.path = "/v1/me/player/play"

            guard let url = components.url else { fatalError() }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let param = [
                "context_uri" : playlist.uri
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: param)

            NSApplication.shared.deactivate()
            let task = URLSession.shared.dataTask(with: request) { _, _, _ in
                exit(0)
            }
            task.resume()
        }
    }


}

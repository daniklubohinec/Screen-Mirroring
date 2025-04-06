//
//  RemoteControllerCovering.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import SwiftUI
import UIKit

struct RemoteControllerCovering {
    private static let tvController = RemoteButtonControllerSetup()
    @State private static var isTVSelectionPresented = false

    static func createTVControlActions() -> RemoteControlActions {
        return RemoteControlActions(
            connect: { name, ipAddr in
                EfficinacyCaller.shared.callHaptic()
                isTVSelectionPresented = true
                tvController.selectTV(name: name, ipAddress: ipAddr)
                tvController.connect()
            },
            power: { tvController.togglePower() },
            settings: { tvController.openSettings() },
            source: { tvController.changeSource() },
            exit: { tvController.exit() },
            navigation: RemoteControlActions.NavigationActions(
                up: { tvController.navigate(direction: "up") },
                down: { tvController.navigate(direction: "down") },
                left: { tvController.navigate(direction: "left") },
                right: { tvController.navigate(direction: "right") },
                ok: { tvController.ok() }
            ),
            return: { tvController.returnAction() },
            home: { tvController.home() },
            media: RemoteControlActions.MediaActions(
                rewind: { tvController.mediaControl(action: "rewind") },
                playPause: { tvController.mediaControl(action: "playPause") },
                fastForward: { tvController.mediaControl(action: "fastForward") }
            ),
            additional: [
                { EfficinacyCaller.shared.callHaptic() },
                { },
                { }
            ],
            channel: RemoteControlActions.ChannelActions(
                up: { tvController.channelControl(action: "up") },
                down: { tvController.channelControl(action: "down") },
                list: { tvController.channelControl(action: "list") }
            ),
            volume: RemoteControlActions.VolumeActions(
                up: { tvController.changeVolume(action: "up") },
                down: { tvController.changeVolume(action: "down") },
                mute: { tvController.changeVolume(action: "mute") }
            )
        )
    }
    
    static func createTVRemoteView() -> UIViewController {
        let actions = createTVControlActions()
        let swiftUIView = RemoteControlView(actions: actions)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.navigationItem.largeTitleDisplayMode = .always
        return hostingController
    }
}

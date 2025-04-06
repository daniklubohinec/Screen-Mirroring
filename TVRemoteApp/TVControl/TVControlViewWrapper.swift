import SwiftUI
import UIKit

struct TVControlViewWrapper {
    private static let tvController = TVController()
    @State private static var isTVSelectionPresented = false

    static func createTVControlActions() -> TVControlActions {
        return TVControlActions(
            connect: { name, ipAddr in
                HapticGenerator.shared.generateImpact()
                isTVSelectionPresented = true
                tvController.selectTV(name: name, ipAddress: ipAddr)
                tvController.connect()
            },
            power: { tvController.togglePower() },
            settings: { tvController.openSettings() },
            source: { tvController.changeSource() },
            exit: { tvController.exit() },
            navigation: TVControlActions.NavigationActions(
                up: { tvController.navigate(direction: "up") },
                down: { tvController.navigate(direction: "down") },
                left: { tvController.navigate(direction: "left") },
                right: { tvController.navigate(direction: "right") },
                ok: { tvController.ok() }
            ),
            return: { tvController.returnAction() },
            home: { tvController.home() },
            media: TVControlActions.MediaActions(
                rewind: { tvController.mediaControl(action: "rewind") },
                playPause: { tvController.mediaControl(action: "playPause") },
                fastForward: { tvController.mediaControl(action: "fastForward") }
            ),
            additional: [
                { HapticGenerator.shared.generateImpact() },
                { },
                { }
            ],
            channel: TVControlActions.ChannelActions(
                up: { tvController.channelControl(action: "up") },
                down: { tvController.channelControl(action: "down") },
                list: { tvController.channelControl(action: "list") }
            ),
            volume: TVControlActions.VolumeActions(
                up: { tvController.changeVolume(action: "up") },
                down: { tvController.changeVolume(action: "down") },
                mute: { tvController.changeVolume(action: "mute") }
            )
        )
    }
    
    static func createTVRemoteView() -> UIViewController {
        let actions = createTVControlActions()
        let swiftUIView = TVControlView(actions: actions)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.navigationItem.largeTitleDisplayMode = .always
        return hostingController
    }
}

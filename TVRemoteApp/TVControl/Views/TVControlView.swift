import SwiftUI

struct TVControlView: View {
    let actions: TVControlActions
    @State private var isVSelectionPresented = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("TV Remote")
                .font(.init(R.font.interBold.callAsFunction(size: 32)!))
                .frame(maxWidth: .infinity, alignment: .leading)
            ConnectBlock(action: { isVSelectionPresented = true })
            PowerSettingsBlock(powerAction: actions.power, settingsAction: actions.settings)
            NavigationBlock(
                sourceAction: actions.source,
                exitAction: actions.exit,
                upAction: actions.navigation.up,
                downAction: actions.navigation.down,
                leftAction: actions.navigation.left,
                rightAction: actions.navigation.right,
                okAction: actions.navigation.ok,
                returnAction: actions.return,
                homeAction: actions.home
            )
            MediaControlBlock(
                rewindAction: actions.media.rewind,
                playPauseAction: actions.media.playPause,
                fastForwardAction: actions.media.fastForward
            )
            AdditionalButtonsBlock(actions: actions.additional)
            VolumeChannelBlock(
                channelUpAction: actions.channel.up,
                channelDownAction: actions.channel.down,
                channelListAction: actions.channel.list,
                volumeUpAction: actions.volume.up,
                volumeDownAction: actions.volume.down,
                muteAction: actions.volume.mute
            )
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $isVSelectionPresented) {
            TVSelectionView(isPresented: $isVSelectionPresented, onTVSelected: { name, ipAddress in
                actions.connect(name, ipAddress)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVControlView(actions: TVControlActions(
            connect: { _, _ in },
            power: {},
            settings: {},
            source: {},
            exit: {},
            navigation: TVControlActions.NavigationActions(
                up: {},
                down: {},
                left: {},
                right: {},
                ok: {}
            ),
            return: {},
            home: {},
            media: TVControlActions.MediaActions(
                rewind: {},
                playPause: {},
                fastForward: {}
            ),
            additional: [{}, {}, {}],
            channel: TVControlActions.ChannelActions(
                up: {},
                down: {},
                list: {}
            ),
            volume: TVControlActions.VolumeActions(
                up: {},
                down: {},
                mute: {}
            )
        ))
    }
}

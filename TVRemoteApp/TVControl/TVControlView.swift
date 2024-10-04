import SwiftUI

struct TVControlActions {
    let connect: (String, String) -> Void
    let power: () -> Void
    let settings: () -> Void
    let source: () -> Void
    let exit: () -> Void
    let navigation: NavigationActions
    let `return`: () -> Void
    let home: () -> Void
    let media: MediaActions
    let additional: [() -> Void]
    let channel: ChannelActions
    let volume: VolumeActions
    
    struct NavigationActions {
        let up: () -> Void
        let down: () -> Void
        let left: () -> Void
        let right: () -> Void
        let ok: () -> Void
    }
    
    struct MediaActions {
        let rewind: () -> Void
        let playPause: () -> Void
        let fastForward: () -> Void
    }
    
    struct ChannelActions {
        let up: () -> Void
        let down: () -> Void
        let list: () -> Void
    }
    
    struct VolumeActions {
        let up: () -> Void
        let down: () -> Void
        let mute: () -> Void
    }
}

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

// Block 1: Connect to TV
struct ConnectBlock: View {
    let action: (() -> Void)
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text("Connect to TV")
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}

// Block 2: Power and Settings
struct PowerSettingsBlock: View {
    let powerAction: () -> Void
    let settingsAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: powerAction) {
                Image(systemName: "power")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .threeDButtonStyle()
            }
            Spacer()
            Button(action: settingsAction) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(RemoteColors.functional)
                    .cornerRadius(10)
                    .threeDButtonStyle()
            }
        }
        .padding(.horizontal, 45)
    }
}

struct NavButton: View {
    let title: String
    let action: () -> Void
    let isHighlighted: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(width: 88, height: 56)
                .background(isHighlighted ? RemoteColors.highlighted : RemoteColors.functional)
                .cornerRadius(10)
        }
        .threeDButtonStyle()
    }
}

// Обновленный Block 3: Navigation
struct NavigationBlock: View {
    let sourceAction: () -> Void
    let exitAction: () -> Void
    let upAction: () -> Void
    let downAction: () -> Void
    let leftAction: () -> Void
    let rightAction: () -> Void
    let okAction: () -> Void
    let returnAction: () -> Void
    let homeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                NavButton(title: "SOURCE", action: sourceAction, isHighlighted: false)
                NavButton(title: "▲", action: upAction, isHighlighted: true)
                NavButton(title: "EXIT", action: exitAction, isHighlighted: false)
            }
            HStack(spacing: 10) {
                NavButton(title: "◀", action: leftAction, isHighlighted: true)
                NavButton(title: "OK", action: okAction, isHighlighted: true)
                NavButton(title: "▶", action: rightAction, isHighlighted: true)
            }
            HStack(spacing: 10) {
                NavButton(title: "RETURN", action: returnAction, isHighlighted: false)
                NavButton(title: "▼", action: downAction, isHighlighted: true)
                NavButton(title: "HOME", action: homeAction, isHighlighted: false)
            }
        }
    }
}

// Block 4: Media Control
struct MediaButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .frame(width: 62, height: 44)
                .background(RemoteColors.functional)
                .cornerRadius(10)
        }
        .threeDButtonStyle()
    }
}

// Обновленный Block 4: Media Control
struct MediaControlBlock: View {
    let rewindAction: () -> Void
    let playPauseAction: () -> Void
    let fastForwardAction: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            MediaButton(systemName: "backward.end.fill", action: rewindAction)
            MediaButton(systemName: "pause.fill", action: playPauseAction)
            MediaButton(systemName: "play.fill", action: playPauseAction)
            MediaButton(systemName: "forward.end.fill", action: fastForwardAction)
        }
    }
}
// Block 5: Volume and Channel
struct ChannelVolumeButton: View {
    let label: String
    let upAction: () -> Void
    let downAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: upAction) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.white)
                    .frame(height: 30)
            }
            Text(label)
                .foregroundColor(.white)
                .frame(height: 30)
            Button(action: downAction) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .frame(height: 30)
            }
        }
        .frame(width: 82, height: 134)
        .background(RemoteColors.volumeChannel)
        .cornerRadius(10)
    }
}

struct ChListButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("CH LIST")
                .font(.system(size: 14))
                .frame(width: 82, height: 60)
                .foregroundColor(.white)
                .background(RemoteColors.functional)
                .cornerRadius(10)
        }
        .threeDButtonStyle()
    }
}

struct MuteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.slash.fill")
                .font(.system(size: 20))
                .frame(width: 82, height: 60)
                .foregroundColor(.white)
                .background(RemoteColors.functional)
                .cornerRadius(10)
        }
        .threeDButtonStyle()
    }
}

// Block 5: Volume and Channel
struct VolumeChannelBlock: View {
    let channelUpAction: () -> Void
    let channelDownAction: () -> Void
    let channelListAction: () -> Void
    let volumeUpAction: () -> Void
    let volumeDownAction: () -> Void
    let muteAction: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ChannelVolumeButton(label: "CH", upAction: channelUpAction, downAction: channelDownAction)
                .threeDButtonStyle()
            VStack(spacing: 10) {
                ChListButton(action: channelListAction)
                MuteButton(action: muteAction)
            }
            ChannelVolumeButton(label: "VOL", upAction: volumeUpAction, downAction: volumeDownAction)
                .threeDButtonStyle()
        }
    }
}

struct AdditionalButton: View {
    let systemName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .frame(width: 50, height: 36)
                .background(isSelected ? RemoteColors.highlighted : RemoteColors.functional)
                .cornerRadius(39)
        }
    }
}

struct AdditionalButtonsBlock: View {
    let actions: [() -> Void]
    @State private var selectedButton = 0
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
                AdditionalButton(
                    systemName: ["circle.grid.cross.fill", "square.grid.2x2", "square.split.2x1"][index],
                    isSelected: selectedButton == index
                ) {
                    selectedButton = index
                    actions[index]()
                }
                .disabled(index > 0)
            }
        }
        .background(RemoteColors.functional)
        .cornerRadius(100)
    }
}

struct RemoteColors {
    static let highlighted = Color(hex: "447AF8")
    static let functional = Color(hex: "1C1C1E")
    static let volumeChannel = Color(hex: "3A3A3B")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
struct ThreeDButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
           content
               .overlay(
                   RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.white.opacity(0.1), lineWidth: 2)
                       .allowsHitTesting(false)
               )
               .overlay(
                   RoundedRectangle(cornerRadius: 10)
                       .fill(Color.white.opacity(0.1))
                       .blur(radius: 1)
                       .offset(x: -1, y: -1)
                       .allowsHitTesting(false)
               )
               .overlay(
                   RoundedRectangle(cornerRadius: 10)
                       .fill(Color.black.opacity(0))
                       .blur(radius: 1)
                       .offset(x: 1, y: 1)
                       .allowsHitTesting(false)
               )
               .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
       }
}

extension View {
    func threeDButtonStyle() -> some View {
        self.modifier(ThreeDButtonStyle())
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

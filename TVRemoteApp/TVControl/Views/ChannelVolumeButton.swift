import SwiftUI

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

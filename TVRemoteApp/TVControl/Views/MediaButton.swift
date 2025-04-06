import SwiftUI

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

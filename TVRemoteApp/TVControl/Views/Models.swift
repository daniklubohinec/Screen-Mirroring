import Foundation
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

struct RemoteColors {
    static let highlighted = Color(hex: "447AF8")
    static let functional = Color(hex: "1C1C1E")
    static let volumeChannel = Color(hex: "3A3A3B")
}

import SwiftUI

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

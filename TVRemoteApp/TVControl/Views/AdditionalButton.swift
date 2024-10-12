import SwiftUI

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

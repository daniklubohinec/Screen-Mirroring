import SwiftUI

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

import SwiftUI

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

import SwiftUI

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

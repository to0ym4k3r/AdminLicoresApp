import SwiftUI
import UIKit

/// Aplica el efecto Liquid Glass cuando el sistema lo soporta (iOS 26+),
/// con un fallback a un material/glass clásico para iOS anteriores.
/// Así la app luce nativa tanto en iPhone 11 (iOS 16-18) como en
/// dispositivos con iOS 26.
struct GlassCardModifier: ViewModifier {

    var tint: Color = .white
    var cornerRadius: CGFloat = 20

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(tint).interactive(),
                             in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            // Fallback: material translúcido con borde y sombra suaves
            content
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                }
                .shadow(color: tint.opacity(0.12), radius: 12, x: 0, y: 6)
        }
    }
}

extension View {
    /// Envuelve la vista en una tarjeta de vidrio (Liquid Glass en iOS 26+,
    /// material translúcido clásico en versiones anteriores).
    func glassCard(tint: Color = .white, cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(tint: tint, cornerRadius: cornerRadius))
    }
}

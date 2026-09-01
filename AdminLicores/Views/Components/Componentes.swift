import SwiftUI

/// Avatar circular con iniciales de un miembro
struct AvatarCirculo: View {
    let iniciales: String
    let color: Color
    var tamano: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: [color.opacity(0.9), color.opacity(0.55)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: tamano, height: tamano)
            Text(iniciales)
                .font(.system(size: tamano * 0.38, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
        .shadow(color: color.opacity(0.25), radius: 5, x: 0, y: 2)
    }
}

/// Contenedor compacto e informativo que aplica el estilo glass chic
struct TarjetaGlass<Content: View>: View {
    var tint: Color = .white
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .glassCard(tint: tint, cornerRadius: cornerRadius)
    }
}

/// Encabezado de sección dentro de las pantallas
struct TituloSeccion: View {
    let titulo: String
    let subtitulo: String
    var color: Color = AppColor.rosaPrincipal

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(titulo)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.textoPrincipal)
            }
            Text(subtitulo)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

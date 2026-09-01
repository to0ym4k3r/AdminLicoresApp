import SwiftUI

/// Paleta de la app: femenina, chic, suave y elegante
enum AppColor {
    // Rosas y lavandas
    static let rosaPrincipal = Color(hex: "E87A9D")
    static let rosaSuave = Color(hex: "F7C6D5")
    static let lavanda = Color(hex: "B79AC8")
    static let lavandaSuave = Color(hex: "E6D5F2")
    static let crema = Color(hex: "FFF7FA")
    static let malva = Color(hex: "C39BD3")

    // Colores temáticos de cada módulo
    static let proveedores = Color(hex: "E8A0B4")
    static let vendedores = Color(hex: "9BB7E8")
    static let viaticos = Color(hex: "F2C36B")
    static let ceo = Color(hex: "D8A7D0")
    static let consumo = Color(hex: "9FCDA6")

    static let textoPrincipal = Color(hex: "4A3B45")
    static let textoSecundario = Color(hex: "9A8C96")

    // Fondo degradado general
    static let fondoDegradado = LinearGradient(
        colors: [Color(hex: "FFF0F6"), Color(hex: "F6EAFB"), Color(hex: "EAF3FB")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 182, 193)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Devuelve el valor hex de un color para guardarlo
    var hexValue: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

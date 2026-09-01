import SwiftUI

/// Fila de un miembro en la lista de personal de oficina.
struct FilaMiembro: View {
    let miembro: MiembroOficina
    let total: Double
    let items: Int

    var body: some View {
        TarjetaGlass(tint: Color(hex: miembro.colorIniciales).opacity(0.45)) {
            HStack(spacing: 14) {
                AvatarCirculo(iniciales: miembro.iniciales,
                              color: Color(hex: miembro.colorIniciales),
                              tamano: 46)
                VStack(alignment: .leading, spacing: 3) {
                    Text(miembro.nombre)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    if !miembro.cargo.isEmpty {
                        Text(miembro.cargo)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "S/ %.2f", total))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Text("\(items) item\(items == 1 ? "" : "s")")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColor.textoSecundario.opacity(0.6))
            }
        }
    }
}

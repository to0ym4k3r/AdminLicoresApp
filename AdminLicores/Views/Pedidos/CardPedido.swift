import SwiftUI

/// Tarjeta individual de un pedido/requerimiento del CEO.
struct CardPedido: View {
    let pedido: PedidoRequerimiento
    let onToggle: () -> Void
    let onEliminar: () -> Void

    var body: some View {
        TarjetaGlass(tint: Color(hex: pedido.prioridad.color).opacity(0.4)) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: pedido.estaCompletado ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(pedido.estaCompletado ? AppColor.consumo : AppColor.textoSecundario.opacity(0.4))
                }
                .buttonStyle(.borderless)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(pedido.titulo)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(pedido.estaCompletado ? AppColor.textoSecundario : AppColor.textoPrincipal)
                            .strikethrough(pedido.estaCompletado, color: AppColor.textoSecundario)
                        Spacer()
                        if !pedido.estaCompletado {
                            Label(pedido.prioridad.rawValue, systemImage: pedido.prioridad.icono)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: pedido.prioridad.color))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: pedido.prioridad.color).opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    if !pedido.descripcion.isEmpty {
                        Text(pedido.descripcion)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }

                    HStack(spacing: 8) {
                        Label("Creado \(pedido.fecha.fechaLarga.capitalized)", systemImage: "calendar")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                        if let limite = pedido.fechaLimite {
                            Text("·")
                            Label("Vence \(limite.fechaLarga.capitalized)", systemImage: "alarm")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(limite < Date() && !pedido.estaCompletado ? Color(hex: "FF7A8A") : AppColor.textoSecundario)
                        }
                    }
                }

                Button(action: onEliminar) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(AppColor.textoSecundario.opacity(0.6))
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

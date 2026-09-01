import SwiftUI

/// Tarjeta de un recordatorio programado en el listado general.
struct CardRecordatorio: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let rec: Recordatorio
    let onToggle: () -> Void

    var body: some View {
        TarjetaGlass(tint: Color(hex: rec.etiquetaColor).opacity(0.5)) {
            HStack(spacing: 14) {
                // Icono según tipo
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: rec.etiquetaColor).opacity(0.25))
                        .frame(width: 48, height: 48)
                    Image(systemName: rec.tipo.icono)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: rec.etiquetaColor))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(rec.titulo)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)

                    HStack(spacing: 8) {
                        Label(rec.nombreDias, systemImage: "calendar")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                        Text("·")
                            .foregroundColor(AppColor.textoSecundario.opacity(0.5))
                        Text(rec.hora.horaCorta)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }

                    if let prox = viewModel.horaProxima(recordatorio: rec) {
                        Text("Próximo: \(prox.fechaLarga.capitalized) · \(prox.horaCorta)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(hex: rec.etiquetaColor))
                    }
                }

                Spacer()

                // Toggle de activación
                Button(action: onToggle) {
                    ZStack {
                        Capsule()
                            .fill(rec.estaActivado ? AppColor.consumo : AppColor.textoSecundario.opacity(0.3))
                            .frame(width: 52, height: 30)
                        HStack {
                            if rec.estaActivado {
                                Spacer()
                            }
                            Circle()
                                .fill(.white)
                                .frame(width: 24, height: 24)
                                .shadow(radius: 1)
                            if !rec.estaActivado {
                                Spacer()
                            }
                        }
                        .padding(3)
                        .frame(width: 52, height: 30)
                    }
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(rec.estaActivado ? "Apagar \(rec.titulo)" : "Encender \(rec.titulo)")
            }
        }
    }
}

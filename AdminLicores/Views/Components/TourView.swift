import SwiftUI

/// Un paso del recorrido guiado por las pestañas de la app.
struct TourPaso: Identifiable {
    let id: Int
    let icono: String
    let titulo: String
    let descripcion: String
}

/// Recorrido guiado (walkthrough) que presenta las pestañas principales.
/// Se usa como overlay en el primer arranque y como sheet desde el toolbar.
struct TourView: View {
    let onFinish: () -> Void
    @State private var pasoActual = 0

    private let pasos: [TourPaso] = [
        TourPaso(id: 0,
                 icono: "bell.fill",
                 titulo: "Hoy",
                 descripcion: "Ves tus recordatorios del día y activa o desactiva cada tarjeta con su botón."),
        TourPaso(id: 1,
                 icono: "mic.fill",
                 titulo: "Notas por voz",
                 descripcion: "Dicta una nota; la app detecta fechas y horas y crea una alarma."),
        TourPaso(id: 2,
                 icono: "fork.knife",
                 titulo: "Oficina",
                 descripcion: "Registra los consumos de almacén de tu personal."),
        TourPaso(id: 3,
                 icono: "briefcase.fill",
                 titulo: "CEO",
                 descripcion: "Administra pedidos y requerimientos importantes."),
        TourPaso(id: 4,
                 icono: "gearshape.fill",
                 titulo: "Ajustes",
                 descripcion: "Gestiona proveedores, vendedores, productos y recordatorios.")
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Button("Saltar", action: onFinish)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)

                tarjeta
            }
            .padding(24)
        }
    }

    private var tarjeta: some View {
        let paso = pasos[pasoActual]
        return VStack(spacing: 22) {
            Image(systemName: paso.icono)
                .font(.system(size: 42, weight: .semibold))
                .foregroundColor(AppColor.rosaPrincipal)
                .frame(width: 96, height: 96)
                .background(Circle().fill(AppColor.rosaSuave.opacity(0.45)))

            VStack(spacing: 8) {
                Text(paso.titulo)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.textoPrincipal)
                Text(paso.descripcion)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColor.textoSecundario)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            puntosProgreso

            HStack(spacing: 12) {
                Button {
                    if pasoActual == pasos.count - 1 {
                        onFinish()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            pasoActual += 1
                        }
                    }
                } label: {
                    Text(pasoActual == pasos.count - 1 ? "OK listo" : "Siguiente")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(AppColor.rosaPrincipal))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(28)
        .glassCard(tint: AppColor.rosaSuave.opacity(0.6), cornerRadius: 28)
    }

    private var puntosProgreso: some View {
        HStack(spacing: 7) {
            ForEach(pasos.indices, id: \.self) { i in
                Capsule()
                    .fill(i == pasoActual ? AppColor.rosaPrincipal : AppColor.rosaSuave.opacity(0.7))
                    .frame(width: i == pasoActual ? 20 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: pasoActual)
    }
}
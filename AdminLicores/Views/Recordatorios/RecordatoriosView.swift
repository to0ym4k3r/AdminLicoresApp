import SwiftUI

/// Pantalla principal: saludo, recordatorios de hoy y listado programado.
struct RecordatoriosView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        resumenHoy
                        listaProgramada
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Hoy")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hola, admin 👋")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Text(Date().fechaLarga.capitalized)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
                Spacer()
                if viewModel.store.recordatorios.contains(where: { $0.estaActivado }) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title2)
                        .foregroundColor(AppColor.rosaPrincipal)
                }
            }
        }
    }

    private var resumenHoy: some View {
        let deHoy = viewModel.store.recordatorios.filter { $0.estaActivado && $0.esHoy }
        return VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Hoy debes hacer",
                          subtitulo: deHoy.isEmpty ? "Sin tareas programadas para hoy" : "\(deHoy.count) tarea\(deHoy.count == 1 ? "" : "s") para hoy",
                          color: AppColor.rosaPrincipal)

            if deHoy.isEmpty {
                TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.4)) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(AppColor.rosaPrincipal)
                        Text("Día libre de recordatorios. ¡Disfruta! ✨")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                    }
                }
            } else {
                ForEach(deHoy.sorted { $0.hora < $1.hora }) { rec in
                    CardRecHoy(rec: rec) { viewModel.alternar(rec) }
                }
            }
        }
    }

    private var listaProgramada: some View {
        VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Recordatorios programados",
                          subtitulo: "Se repiten cada semana en los días marcados",
                          color: AppColor.lavanda)

            ForEach(viewModel.recordatoriosOrdenados) { rec in
                CardRecordatorio(rec: rec) {
                    viewModel.alternar(rec)
                }
            }
        }
    }
}

/// Tarjeta para un recordatorio que toca HOY
private struct CardRecHoy: View {
    let rec: Recordatorio
    let onToggle: () -> Void

    var body: some View {
        TarjetaGlass(tint: Color(hex: rec.etiquetaColor).opacity(0.5)) {
            HStack(spacing: 14) {
                Image(systemName: rec.tipo.icono)
                    .font(.title2)
                    .foregroundColor(AppColor.rosaPrincipal)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text(rec.titulo)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Text("\(rec.hora.horaCorta)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
                Spacer()
                Button(action: onToggle) {
                    Image(systemName: rec.estaActivado ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(rec.estaActivado ? AppColor.consumo : AppColor.textoSecundario.opacity(0.4))
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

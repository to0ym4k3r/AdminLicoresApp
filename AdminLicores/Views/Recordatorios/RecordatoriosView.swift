import SwiftUI

/// Pantalla principal: saludo, recordatorios de hoy y listado programado.
struct RecordatoriosView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var mostrarVoz = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        resumenHoy
                        notaVoz
                        listaProgramada
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Hoy")
            .sheet(isPresented: $mostrarVoz) {
                VozNotaSheet()
            }
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

    private var notaVoz: some View {
        let notas = viewModel.store.notas.sorted { $0.fechaRegistro > $1.fechaRegistro }
        return VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Notas por voz",
                          subtitulo: "Dicta una nota y crea tu propia alarma",
                          color: AppColor.rosaSuave)

            Button {
                mostrarVoz = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.rosaSuave.opacity(0.5))
                            .frame(width: 42, height: 42)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColor.rosaPrincipal)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Grabar nota por voz")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                        Text("Detecta fechas y horas automáticamente")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColor.textoSecundario.opacity(0.6))
                }
                .padding(16)
                .glassCard(tint: AppColor.rosaSuave.opacity(0.4))
                .foregroundColor(AppColor.textoPrincipal)
            }
            .buttonStyle(.plain)

            if notas.isEmpty {
                TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.35)) {
                    Text("Dicta una nota y la app creará la alarma por vos. ✨")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
            } else {
                ForEach(notas) { nota in
                    CardNotaVoz(nota: nota) {
                        withAnimation {
                            viewModel.eliminarNotaVoz(nota)
                        }
                    }
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

/// Tarjeta de una nota por voz guardada
private struct CardNotaVoz: View {
    let nota: NotaVoz
    let onEliminar: () -> Void

    var body: some View {
        TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.35)) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundColor(AppColor.rosaPrincipal)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 6) {
                    Text(nota.texto)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        if let fecha = nota.fechaDetectada {
                            Label("Alarma \(formatoCorto(fecha))", systemImage: "alarm.fill")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColor.rosaPrincipal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColor.rosaSuave.opacity(0.5))
                                .clipShape(Capsule())
                        }
                        Label("Registrada \(formatoCorto(nota.fechaRegistro))", systemImage: "clock")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }
                }

                Spacer()

                Button(action: onEliminar) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(AppColor.textoSecundario.opacity(0.6))
                }
                .buttonStyle(.borderless)
                .padding(.top, 2)
            }
        }
    }

    private func formatoCorto(_ fecha: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateFormat = "dd/MM HH:mm"
        return f.string(from: fecha)
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

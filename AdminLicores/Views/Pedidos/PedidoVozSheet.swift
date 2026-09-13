import SwiftUI
import UIKit

/// Sheet de dictado por voz para crear un pendiente del CEO: graba el
/// requerimiento, detecta la fecha límite en el texto y lo guarda.
struct PedidoVozSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var servicio = DictadoServicio()
    @State private var texto: String = ""
    @State private var detectada: Date?
    @State private var mostrarAlertaPermiso = false
    @State private var mostrandoError = false

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    encabezado
                    botonMicrofono
                    if servicio.estaGrabando {
                        textoVivo
                    } else {
                        editorTexto
                    }
                    chipFecha
                    botonGuardar
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .task {
            let concedido = await servicio.solicitarPermiso()
            if !concedido {
                mostrarAlertaPermiso = true
            }
        }
        .onChange(of: texto) { nuevoTexto in
            detectada = viewModel.deteccionPara(nuevoTexto)
        }
        .onChange(of: servicio.estaGrabando) { grabando in
            // Si el reconocimiento finaliza solo, adopta el texto reconocido.
            if !grabando && texto.isEmpty {
                texto = servicio.textoParcial
            }
        }
        .onChange(of: servicio.errorMensaje) { mensaje in
            if mensaje != nil {
                mostrandoError = true
            }
        }
        .alert("Permisos necesarios", isPresented: $mostrarAlertaPermiso) {
            Button("Ir a Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para dictar notas por voz, la app necesita acceso al micrófono y al reconocimiento de voz. Puedes habilitarlos desde los Ajustes del iPhone.")
        }
    }

    // MARK: - Secciones

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pendiente por voz 🎤")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.textoPrincipal)
            Text("Dicta el requerimiento y la app detecta la fecha límite")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
        }
    }

    private var botonMicrofono: some View {
        VStack(spacing: 10) {
            Button(action: tocarMicrofono) {
                ZStack {
                    Circle()
                        .fill(servicio.estaGrabando
                              ? Color(hex: "FF5A5F")
                              : Color(hex: "B9B0BC"))
                        .frame(width: 86, height: 86)
                        .shadow(color: (servicio.estaGrabando
                                        ? Color(hex: "FF5A5F")
                                        : Color(hex: "B9B0BC")).opacity(0.35),
                                radius: 10, x: 0, y: 5)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(servicio.estaGrabando ? 1.08 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: servicio.estaGrabando)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(servicio.estaGrabando ? "Detener grabación" : "Iniciar grabación")

            Text(servicio.estaGrabando ? "Grabando… toca para detener" : "Toca el micrófono y dicta el requerimiento")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
        }
        .frame(maxWidth: .infinity)
        .alert("No se pudo reconocer el audio", isPresented: $mostrandoError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(servicio.errorMensaje ?? "Intenta de nuevo.")
        }
    }

    private var textoVivo: some View {
        TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.45)) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundColor(Color(hex: "FF5A5F"))
                Text(servicio.textoParcial.isEmpty
                     ? "Te escucho…"
                     : servicio.textoParcial)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(AppColor.textoPrincipal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var editorTexto: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $texto)
                .font(.system(size: 15, design: .rounded))
                .frame(minHeight: 130)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.65))
                )
            if texto.isEmpty {
                Text("El texto dictado aparecerá aquí y podrás editarlo…")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(AppColor.textoSecundario.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .allowsHitTesting(false)
            }
        }
    }

    private var chipFecha: some View {
        Group {
            if let fecha = detectada, fecha > Date() {
                HStack(spacing: 10) {
                    Text("📅 \(formatoLargo(fecha))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.rosaPrincipal)
                    Spacer()
                    Label("Fecha límite", systemImage: "calendar")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.rosaPrincipal)
                }
                .padding(14)
                .glassCard(tint: AppColor.rosaSuave.opacity(0.5), cornerRadius: 16)
            }
        }
    }

    private var botonGuardar: some View {
        let hayFechaLimite = detectada.map { $0 > Date() } ?? false
        return Button {
            viewModel.agregarPedidoPorVoz(texto: texto, fechaLimite: detectada)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: hayFechaLimite ? "calendar.badge.plus" : "mic.fill")
                Text(hayFechaLimite ? "Guardar con fecha límite" : "Guardar pendiente")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Capsule().fill(AppColor.rosaPrincipal))
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .disabled(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }

    // MARK: - Acciones

    private func tocarMicrofono() {
        if servicio.estaGrabando {
            let resultado = servicio.detener()
            if !resultado.isEmpty {
                texto = resultado
            }
        } else {
            texto = ""
            detectada = nil
            do {
                try servicio.iniciar()
            } catch {
                servicio.errorMensaje = error.localizedDescription
            }
        }
    }

    private func formatoLargo(_ fecha: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateFormat = "dd/MM/yyyy HH:mm"
        return f.string(from: fecha)
    }
}
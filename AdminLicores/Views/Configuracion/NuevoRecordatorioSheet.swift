import SwiftUI

/// Sheet para crear un recordatorio personalizado con días y hora elegidos.
struct NuevoRecordatorioSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var titulo = ""
    @State private var detalle = ""
    @State private var hora = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var diasSeleccionados: Set<Int> = []

    private let nombresDias = ["L", "M", "X", "J", "V", "S", "D"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Título y detalle
                        VStack(alignment: .leading, spacing: 10) {
                            CampoEdicion(titulo: "Título",
                                         placeholder: "Ej. Llamar a proveedores",
                                         texto: $titulo)
                            CampoEdicion(titulo: "Detalle (opcional)",
                                         placeholder: "¿Qué debes hacer?",
                                         texto: $detalle)
                        }

                        // Hora
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hora")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)
                            DatePicker("Hora del recordatorio", selection: $hora, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                                .padding(12)
                                .glassCard(tint: AppColor.rosaSuave.opacity(0.4))
                        }

                        // Días de la semana
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Días de repetición")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)
                            HStack(spacing: 8) {
                                ForEach(1...7, id: \.self) { dia in
                                    Button {
                                        toggleDia(dia)
                                    } label: {
                                        Text(nombresDias[dia - 1])
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .frame(width: 42, height: 42)
                                            .background(Circle().fill(diasSeleccionados.contains(dia)
                                                                      ? AppColor.rosaPrincipal
                                                                      : Color.white.opacity(0.6)))
                                            .foregroundColor(diasSeleccionados.contains(dia)
                                                             ? .white : AppColor.textoSecundario)
                                            .overlay(Circle().strokeBorder(AppColor.rosaPrincipal.opacity(0.3), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Nuevo recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .disabled(titulo.trimmingCharacters(in: .whitespaces).isEmpty || diasSeleccionados.isEmpty)
                }
            }
        }
    }

    private func toggleDia(_ dia: Int) {
        if diasSeleccionados.contains(dia) {
            diasSeleccionados.remove(dia)
        } else {
            diasSeleccionados.insert(dia)
        }
    }

    private func guardar() {
        let rec = Recordatorio(
            titulo: titulo.trimmingCharacters(in: .whitespaces),
            detalle: detalle.trimmingCharacters(in: .whitespaces),
            tipo: .personalizado,
            diasSemana: diasSeleccionados,
            hora: hora,
            etiquetaColor: AppColor.rosaPrincipal.hexValue
        )
        withAnimation { viewModel.store.recordatorios.append(rec) }
        Task { await NotificationScheduler.shared.programar(rec) }
        dismiss()
    }
}

/// Campo de texto con etiqueta, estilizado para la app
struct CampoEdicion: View {
    let titulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
            TextField(placeholder, text: $texto)
                .font(.system(size: 15, design: .rounded))
                .padding(14)
                .glassCard(tint: AppColor.rosaSuave.opacity(0.3))
        }
    }
}

import SwiftUI

/// Sheet to edit an existing scheduled reminder: title, detail, time and weekdays.
struct EditarRecordatorioSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let rec: Recordatorio

    @State private var titulo: String
    @State private var detalle: String
    @State private var hora: Date
    @State private var diasSeleccionados: Set<Int>

    private let nombresDias = ["L", "M", "X", "J", "V", "S", "D"]

    init(rec: Recordatorio) {
        self.rec = rec
        _titulo = State(initialValue: rec.titulo)
        _detalle = State(initialValue: rec.detalle)
        _hora = State(initialValue: rec.hora)
        _diasSeleccionados = State(initialValue: rec.diasSemana)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Title and detail
                        VStack(alignment: .leading, spacing: 10) {
                            CampoEdicion(titulo: "Título",
                                         placeholder: "Ej. Llamar a proveedores",
                                         texto: $titulo)
                            CampoEdicion(titulo: "Detalle (opcional)",
                                         placeholder: "¿Qué debes hacer?",
                                         texto: $detalle)
                        }

                        // Time
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

                        // Weekdays
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
            .navigationTitle("Editar recordatorio")
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
        let editado = Recordatorio(id: rec.id,
                                   titulo: titulo.trimmingCharacters(in: .whitespaces),
                                   detalle: detalle.trimmingCharacters(in: .whitespaces),
                                   tipo: rec.tipo,
                                   diasSemana: diasSeleccionados,
                                   hora: hora,
                                   estaActivado: rec.estaActivado,
                                   ultimoDisparo: rec.ultimoDisparo,
                                   etiquetaColor: rec.etiquetaColor)
        withAnimation { viewModel.actualizar(editado) }
        dismiss()
    }
}
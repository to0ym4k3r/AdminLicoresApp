import SwiftUI

/// Sheet para ingresar un nuevo pedido o requerimiento del CEO.
struct NuevoPedidoSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var titulo = ""
    @State private var descripcion = ""
    @State private var prioridad: Prioridad = .media
    @State private var tieneFechaLimite = false
    @State private var fechaLimite = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                Form {
                    Section("Requerimiento") {
                        TextField("Título", text: $titulo)
                        TextField("Descripción (opcional)", text: $descripcion, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section("Prioridad") {
                        Picker("Prioridad", selection: $prioridad) {
                            ForEach(Prioridad.allCases) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Fecha límite") {
                        Toggle("Definir fecha límite", isOn: $tieneFechaLimite)
                        if tieneFechaLimite {
                            DatePicker("Vence", selection: $fechaLimite, displayedComponents: .date)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Nuevo requerimiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.agregarPedido(titulo: titulo,
                                                descripcion: descripcion,
                                                prioridad: prioridad,
                                                fechaLimite: tieneFechaLimite ? fechaLimite : nil)
                        dismiss()
                    }
                    .disabled(titulo.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

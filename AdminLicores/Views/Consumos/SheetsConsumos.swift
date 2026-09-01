import SwiftUI

/// Sheet para dar de alta a un nuevo miembro del personal de oficina.
struct NuevoMiembroSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var cargo = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                Form {
                    Section("Datos del miembro") {
                        TextField("Nombre completo", text: $nombre)
                        TextField("Cargo (opcional)", text: $cargo)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Nuevo miembro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        viewModel.agregarMiembro(nombre: nombre, cargo: cargo)
                        dismiss()
                    }
                    .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

/// Sheet para crear un producto del almacén.
struct NuevoProductoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onCrear: (String, String, Double) -> Void

    @State private var nombre = ""
    @State private var categoria = ""
    @State private var precioTexto = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                Form {
                    Section("Producto del almacén") {
                        TextField("Nombre del producto", text: $nombre)
                        TextField("Categoría (opcional)", text: $categoria)
                        TextField("Precio unitario", text: $precioTexto)
                            .keyboardType(.decimalPad)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Nuevo producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let precio = Double(precioTexto.replacingOccurrences(of: ",", with: ".")) ?? 0
                        onCrear(nombre, categoria, precio)
                        dismiss()
                    }
                    .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

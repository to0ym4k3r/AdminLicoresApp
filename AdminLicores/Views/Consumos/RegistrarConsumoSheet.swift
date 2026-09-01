import SwiftUI

/// Sheet para registrar un consumo de almacén para un miembro.
struct RegistrarConsumoSheet: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    let miembro: MiembroOficina
    let onRegistrar: (ProductoConsumo, Int) -> Void

    @State private var productoSeleccionado: ProductoConsumo?
    @State private var cantidad: Int = 1
    @State private var mostrarNuevoProducto = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Encabezado con avatar
                        HStack(spacing: 14) {
                            AvatarCirculo(iniciales: miembro.iniciales,
                                          color: Color(hex: miembro.colorIniciales),
                                          tamano: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Registrando para")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(AppColor.textoSecundario)
                                Text(miembro.nombre)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColor.textoPrincipal)
                            }
                        }

                        // Selector de producto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Producto del almacén")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)

                            Menu {
                                ForEach(viewModel.store.productos) { p in
                                    Button {
                                        productoSeleccionado = p
                                    } label: {
                                        Label("\(p.nombre)  ·  \(String(format: "S/ %.2f", p.precioUnitario))",
                                              systemImage: productoSeleccionado?.id == p.id ? "checkmark" : "")
                                    }
                                }
                                Divider()
                                Button {
                                    mostrarNuevoProducto = true
                                } label: {
                                    Label("Agregar producto nuevo", systemImage: "plus")
                                }
                            } label: {
                                HStack {
                                    if let p = productoSeleccionado {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(p.nombre)
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(AppColor.textoPrincipal)
                                            Text(String(format: "S/ %.2f c/u", p.precioUnitario))
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(AppColor.textoSecundario)
                                        }
                                    } else {
                                        Text("Elegir producto")
                                            .font(.system(size: 15, design: .rounded))
                                            .foregroundColor(AppColor.textoSecundario)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(AppColor.textoSecundario)
                                }
                                .padding(16)
                                .glassCard(tint: AppColor.consumo.opacity(0.4))
                            }
                        }

                        // Selector de cantidad
                        if productoSeleccionado != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cantidad")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColor.textoSecundario)
                                HStack {
                                    Button { if cantidad > 1 { cantidad -= 1 } } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(AppColor.rosaPrincipal)
                                    }
                                    Text("\(cantidad)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColor.textoPrincipal)
                                        .frame(minWidth: 60)
                                    Button { cantidad += 1 } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(AppColor.rosaPrincipal)
                                    }
                                    Spacer()
                                    if let p = productoSeleccionado {
                                        Text(viewModel.moneda(Double(cantidad) * p.precioUnitario))
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .foregroundColor(AppColor.textoPrincipal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Registrar consumo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard let p = productoSeleccionado else { return }
                        onRegistrar(p, cantidad)
                        dismiss()
                    }
                    .disabled(productoSeleccionado == nil)
                }
            }
            .sheet(isPresented: $mostrarNuevoProducto) {
                NuevoProductoSheet { nombre, categoria, precio in
                    viewModel.agregarProducto(nombre: nombre, categoria: categoria, precio: precio)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

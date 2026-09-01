import SwiftUI

/// Gestión del catálogo de productos del almacén consumidos en oficina.
struct GestionProductosView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var mostrarNuevo = false

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TarjetaGlass(tint: AppColor.consumo.opacity(0.4)) {
                        Text("Catálogo de productos que el personal consume del almacén. Estos se facturan y descuentan a fin de mes.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                    }

                    ForEach(viewModel.store.productos) { p in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(p.nombre)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColor.textoPrincipal)
                                if !p.categoria.isEmpty {
                                    Text(p.categoria)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(AppColor.textoSecundario)
                                }
                            }
                            Spacer()
                            Text(viewModel.moneda(p.precioUnitario))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.textoPrincipal)
                            Button {
                                withAnimation { viewModel.store.productos.removeAll { $0.id == p.id } }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(AppColor.textoSecundario.opacity(0.6))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(14)
                        .glassCard(tint: .white.opacity(0.4), cornerRadius: 16)
                    }

                    Button {
                        mostrarNuevo = true
                    } label: {
                        Label("Agregar producto", systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColor.consumo)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Productos")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarNuevo) {
            NuevoProductoSheet { nombre, categoria, precio in
                viewModel.agregarProducto(nombre: nombre, categoria: categoria, precio: precio)
            }
        }
    }
}

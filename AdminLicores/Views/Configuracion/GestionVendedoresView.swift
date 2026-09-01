import SwiftUI

/// Gestión de la lista de vendedores que reciben avances (Mar, Jue, Sáb),
/// con nombre editables, zona y teléfono.
struct GestionVendedoresView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TarjetaGlass(tint: AppColor.vendedores.opacity(0.4)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Avances por vendedor")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.textoPrincipal)
                            Text("Reciben avances los martes, jueves y sábados. Añade, edita y elimina tus vendedores:")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)
                        }
                    }

                    // Botón para añadir un vendedor
                    Button {
                        let nuevo = Vendedor(nombre: "Vendedor \(viewModel.store.vendedores.count + 1)")
                        viewModel.store.vendedores.append(nuevo)
                    } label: {
                        Label("Agregar vendedor", systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColor.vendedores)
                    }

                    ForEach(viewModel.store.vendedores) { vendedor in
                        tarjetaVendedor(vendedor)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Vendedores")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Tarjeta editable de un vendedor (nombre, zona y teléfono).
    private func tarjetaVendedor(_ vendedor: Vendedor) -> some View {
        TarjetaGlass(tint: AppColor.vendedores.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    AvatarCirculo(iniciales: vendedor.iniciales,
                                  color: AppColor.vendedores,
                                  tamano: 34)
                    TextField("Nombre", text: bindingNombre(vendedor))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Spacer()
                    Button {
                        viewModel.store.vendedores.removeAll { $0.id == vendedor.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "FF7A8A"))
                    }
                    .buttonStyle(.borderless)
                }

                HStack(spacing: 12) {
                    Label {
                        TextField("Zona", text: bindingZona(vendedor))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(AppColor.vendedores.opacity(0.7))
                    }

                    Label {
                        TextField("Teléfono", text: bindingTelefono(vendedor))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                            .keyboardType(.phonePad)
                    } icon: {
                        Image(systemName: "phone.fill")
                            .foregroundColor(AppColor.vendedores.opacity(0.7))
                    }
                }
                .padding(.top, 2)
            }
        }
    }

    // MARK: - Bindings a los campos editables dentro del array

    private func bindingNombre(_ vendedor: Vendedor) -> Binding<String> {
        Binding(
            get: { vendedor.nombre },
            set: { nuevo in
                if let idx = viewModel.store.vendedores.firstIndex(where: { $0.id == vendedor.id }) {
                    viewModel.store.vendedores[idx].nombre = nuevo
                }
            }
        )
    }

    private func bindingZona(_ vendedor: Vendedor) -> Binding<String> {
        Binding(
            get: { vendedor.zona },
            set: { nuevo in
                if let idx = viewModel.store.vendedores.firstIndex(where: { $0.id == vendedor.id }) {
                    viewModel.store.vendedores[idx].zona = nuevo
                }
            }
        )
    }

    private func bindingTelefono(_ vendedor: Vendedor) -> Binding<String> {
        Binding(
            get: { vendedor.telefono },
            set: { nuevo in
                if let idx = viewModel.store.vendedores.firstIndex(where: { $0.id == vendedor.id }) {
                    viewModel.store.vendedores[idx].telefono = nuevo
                }
            }
        )
    }
}
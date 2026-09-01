import SwiftUI

/// Gestión de la lista de proveedores que reciben avances (Lun, Mar, Mié).
struct GestionProveedoresView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var lista = [""]
    @State private var mostrarError = false

    private let maxProveedores = 3

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TarjetaGlass(tint: AppColor.proveedores.opacity(0.4)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Avances a proveedores")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.textoPrincipal)
                            Text("Reciben avances los lunes, martes y miércoles. Edita sus nombres:")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)
                        }
                    }

                    ForEach(lista.indices, id: \.self) { idx in
                        HStack {
                            TextField("Proveedor \(idx + 1)", text: $lista[idx])
                                .font(.system(size: 15, design: .rounded))
                                .padding(14)
                                .glassCard(tint: AppColor.proveedores.opacity(0.3))
                            if lista.count > 1 {
                                Button {
                                    lista.remove(at: idx)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color(hex: "FF7A8A"))
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }

                    Button {
                        if lista.count < maxProveedores {
                            lista.append("")
                        } else {
                            mostrarError = true
                        }
                    } label: {
                        Label("Agregar proveedor", systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColor.proveedores)
                    }
                    .disabled(lista.count >= maxProveedores)

                    Text("Puedes tener hasta \(maxProveedores) proveedores.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
                .padding(20)
            }
        }
        .navigationTitle("Proveedores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: cargar)
        .onDisappear(perform: guardar)
        .alert("Límite alcanzado", isPresented: $mostrarError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ya tienes \(maxProveedores) proveedores configurados.")
        }
    }

    private func cargar() {
        if viewModel.store.proveedores.isEmpty {
            lista = viewModel.store.proveedoresPorDefecto
        } else {
            lista = viewModel.store.proveedores
        }
    }

    private func guardar() {
        let limpio = lista.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        viewModel.store.proveedores = limpio.isEmpty ? viewModel.store.proveedoresPorDefecto : limpio
    }
}

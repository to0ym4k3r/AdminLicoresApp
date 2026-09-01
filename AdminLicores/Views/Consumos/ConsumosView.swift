import SwiftUI

/// Pantalla de consumo de oficina: registrar consumos por miembro,
/// ver resumen del mes y preparar la facturación de fin de mes.
struct ConsumosView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var rutaMiembro: UUID?
    @State private var mostrarCompartir = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        tarjetaResumenMes
                        seccionMiembros
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Oficina")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostrarCompartir = true
                    } label: {
                        Image(systemName: "doc.text")
                    }
                }
            }
            .sheet(isPresented: $mostrarCompartir) {
                FacturacionView()
            }
        }
    }

    private var tarjetaResumenMes: some View {
        VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Consumos de \(Date().mesActual.capitalized)",
                          subtitulo: "Se factura y descuenta a fin de mes",
                          color: AppColor.consumo)

            TarjetaGlass(tint: AppColor.consumo.opacity(0.45)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total del mes")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColor.textoSecundario)
                        Text(viewModel.moneda(viewModel.totalConsumoMes()))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                    }
                    Spacer()
                    Button {
                        mostrarCompartir = true
                    } label: {
                        Label("Facturar", systemImage: "checkmark.shield.fill")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(AppColor.textoPrincipal)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var seccionMiembros: some View {
        VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Personal de oficina",
                          subtitulo: "Toca un miembro para registrar o ver sus consumos",
                          color: AppColor.rosaSuave)

            VStack(spacing: 12) {
                ForEach(viewModel.store.miembros) { miembro in
                    NavigationLink {
                        MiembroDetalleView(miembro: miembro)
                    } label: {
                        FilaMiembro(miembro: miembro,
                                    total: viewModel.totalConsumo(miembro: miembro),
                                    items: viewModel.cantidadConsumos(miembro: miembro))
                    }
                    .buttonStyle(.plain)
                }

                // Opción para agregar miembro
                Button {
                    mostrarMiembro = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Agregar miembro")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    .padding(16)
                    .glassCard(tint: AppColor.lavanda.opacity(0.4))
                    .foregroundColor(AppColor.lavanda)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $mostrarMiembro) {
            NuevoMiembroSheet()
        }
    }

    @State private var mostrarMiembro = false
}

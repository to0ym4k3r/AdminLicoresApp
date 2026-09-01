import SwiftUI

/// Detalle de un miembro: registrar consumos de almacén y ver su historial mensual.
struct MiembroDetalleView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let miembro: MiembroOficina

    @State private var productoSeleccionado: ProductoConsumo?
    @State private var cantidad: Int = 1
    @State private var mostrarRegistro = false

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    cabecera
                    botonRegistrar
                    totalMes
                    historial
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle(miembro.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarRegistro) {
            RegistrarConsumoSheet(miembro: miembro) { producto, cant in
                viewModel.registrarConsumo(miembro: miembro, producto: producto, cantidad: cant)
            }
        }
    }

    private var cabecera: some View {
        HStack(spacing: 16) {
            AvatarCirculo(iniciales: miembro.iniciales,
                          color: Color(hex: miembro.colorIniciales),
                          tamano: 60)
            VStack(alignment: .leading, spacing: 3) {
                Text(miembro.nombre)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.textoPrincipal)
                if !miembro.cargo.isEmpty {
                    Text(miembro.cargo)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
            }
            Spacer()
        }
    }

    private var botonRegistrar: some View {
        Button {
            mostrarRegistro = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Registrar consumo de almacén")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
            }
            .padding(16)
            .glassCard(tint: AppColor.consumo.opacity(0.5))
            .foregroundColor(AppColor.textoPrincipal)
        }
        .buttonStyle(.plain)
    }

    private var totalMes: some View {
        TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.4)) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Consumido en \(Date().mesActual.capitalized)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                    Text(viewModel.moneda(viewModel.totalConsumo(miembro: miembro)))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                }
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(AppColor.consumo)
            }
        }
    }

    private var historial: some View {
        let consumos = viewModel.consumosDe(miembro: miembro, enMes: Date())
        return VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Historial del mes",
                          subtitulo: consumos.isEmpty ? "Aún no hay consumos este mes" : "\(consumos.count) registro\(consumos.count == 1 ? "" : "s")",
                          color: AppColor.consumo)

            if consumos.isEmpty {
                TarjetaGlass {
                    Text("Toca \"Registrar consumo\" para anotar productos tomados del almacén. ✨")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(consumos) { c in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(c.cantidad) × \(c.nombreProducto)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColor.textoPrincipal)
                            Text(c.fecha.fechaLarga.capitalized)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(AppColor.textoSecundario)
                        }
                        Spacer()
                        Text(viewModel.moneda(c.subtotal))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(AppColor.textoPrincipal)
                        Button {
                            withAnimation {
                                viewModel.eliminarConsumo(c)
                            }
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
            }
        }
    }
}

import SwiftUI

/// Resumen de fin de mes: detalle por miembro para facturar y descontar
/// los productos consumidos del almacén.
struct FacturacionView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        detallePorMiembro
                        totalGeneral
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Facturación de \(Date().mesActual.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }

    private var detallePorMiembro: some View {
        let resumen = viewModel.resumenFacturacionMes()
        return VStack(alignment: .leading, spacing: 14) {
            TituloSeccion(titulo: "Consumos por miembro",
                          subtitulo: "Para descuento a fin de mes",
                          color: AppColor.consumo)

            if resumen.isEmpty {
                TarjetaGlass {
                    Text("No hay consumos registrados este mes. El total a facturar es S/ 0.00.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
            } else {
                ForEach(resumen) { item in
                    TarjetaGlass(tint: Color(hex: item.miembro.colorIniciales).opacity(0.45)) {
                        HStack(spacing: 14) {
                            AvatarCirculo(iniciales: item.miembro.iniciales,
                                          color: Color(hex: item.miembro.colorIniciales),
                                          tamano: 40)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.miembro.nombre)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColor.textoPrincipal)
                                Text("\(item.cantidadItems) item\(item.cantidadItems == 1 ? "" : "s")")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(AppColor.textoSecundario)
                            }
                            Spacer()
                            Text(viewModel.moneda(item.total))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.textoPrincipal)
                        }
                    }
                }
            }
        }
    }

    private var totalGeneral: some View {
        TarjetaGlass(tint: AppColor.consumo.opacity(0.5)) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TOTAL A FACTURAR")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                    Text(viewModel.moneda(viewModel.totalConsumoMes()))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                }
                Spacer()
                Image(systemName: "doc.plaintext.fill")
                    .font(.system(size: 34))
                    .foregroundColor(AppColor.consumo)
            }
        }
    }
}

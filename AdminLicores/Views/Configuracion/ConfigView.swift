import SwiftUI

/// Pantalla de ajustes y configuración de la app.
struct ConfigView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        encabezado
                        seccionRecordatorios
                        seccionProveedores
                        seccionProductos
                        seccionNotificaciones
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Ajustes")
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Personaliza tu app")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.textoPrincipal)
            Text("Administra proveedores, vendedores, recordatorios y productos")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
        }
    }

    private var seccionRecordatorios: some View {
        VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Recordatorios",
                          subtitulo: "Crea recordatorios personalizados",
                          color: AppColor.rosaPrincipal)
            NavigationLink {
                GestionRecordatoriosView()
            } label: {
                FilaAjuste(icono: "bell.badge.fill", color: AppColor.rosaPrincipal,
                           titulo: "Mis recordatorios",
                           subtitulo: "\(viewModel.store.recordatorios.count) programados")
            }
        }
    }

    private var seccionProveedores: some View {
        VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Proveedores y vendedores",
                          subtitulo: "Edita los nombres de tus contactos",
                          color: AppColor.proveedores)
            NavigationLink {
                GestionProveedoresView()
            } label: {
                FilaAjuste(icono: "truck.box.fill", color: AppColor.proveedores,
                           titulo: "Proveedores",
                           subtitulo: viewModel.store.proveedores.isEmpty
                                ? "\(viewModel.store.proveedoresPorDefecto.count) por defecto"
                                : viewModel.store.proveedores.joined(separator: ", "))
            }
            NavigationLink {
                GestionVendedoresView()
            } label: {
                FilaAjuste(icono: "person.2.fill", color: AppColor.vendedores,
                           titulo: "Vendedores",
                           subtitulo: viewModel.store.vendedores.isEmpty
                                ? "Sin vendedores aún"
                                : "\(viewModel.store.vendedores.count) configurados")
            }
        }
    }

    private var seccionProductos: some View {
        VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Almacén",
                          subtitulo: "Catálogo de productos consumidos en oficina",
                          color: AppColor.consumo)
            NavigationLink {
                GestionProductosView()
            } label: {
                FilaAjuste(icono: "shippingbox.fill", color: AppColor.consumo,
                           titulo: "Productos de oficina",
                           subtitulo: "\(viewModel.store.productos.count) productos")
            }
        }
    }

    private var seccionNotificaciones: some View {
        VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Notificaciones",
                          subtitulo: "Para no olvidar tus recordatorios",
                          color: AppColor.viaticos)
            Button {
                Task { _ = await NotificationScheduler.shared.solicitarPermiso() }
            } label: {
                FilaAjuste(icono: "bell.and.waves.left.and.right.fill", color: AppColor.viaticos,
                           titulo: "Permitir notificaciones",
                           subtitulo: "Toca para asegurar que lleguen")
            }
        }
    }
}

/// Fila reutilizable de ajuste
struct FilaAjuste: View {
    let icono: String
    let color: Color
    let titulo: String
    let subtitulo: String

    var body: some View {
        TarjetaGlass(tint: color.opacity(0.4)) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.2))
                        .frame(width: 42, height: 42)
                    Image(systemName: icono)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(titulo)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Text(subtitulo)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColor.textoSecundario.opacity(0.6))
            }
        }
    }
}

import SwiftUI

/// Pedidos y requerimientos registrados por el CEO (Renzo Campos).
struct PedidosView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var mostrarNuevo = false
    @State private var mostrarUndo = false
    @State private var undoRem = 3
    @State private var undoTimer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.fondoDegradado.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCEO
                        listaPendientes
                        listaCompletados
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .overlay(alignment: .bottom) {
                if mostrarUndo {
                    barraUndo
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("CEO")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostrarNuevo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarNuevo) {
                NuevoPedidoSheet()
            }
        }
    }

    /// Barra flotante inferior de "Deshacer", inspirada en Gmail.
    private var barraUndo: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            Text("Pedido eliminado")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Button {
                viewModel.restaurarUltimoPedidoEliminado()
                ocultarUndo()
            } label: {
                Text("Deshacer")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.rosaSuave)
            }
            .buttonStyle(.borderless)
            Text("\(undoRem)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "F2C36B"))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "4A3B45"))
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        )
    }

    /// Muestra la barra de deshacer e inicia el contador de 3 segundos.
    private func iniciarUndo() {
        guard viewModel.ultimoPedidoEliminado != nil else { return }
        // Detener cualquier temporizador previo sin borrar el pedido a restaurar.
        undoTimer?.invalidate()
        undoTimer = nil
        undoRem = 3
        mostrarUndo = true
        undoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if undoRem > 1 {
                undoRem -= 1
            } else {
                timer.invalidate()
                ocultarUndo()
            }
        }
    }

    /// Oculta la barra y limpia el estado (tanto al deshacer como al expirar).
    private func ocultarUndo() {
        undoTimer?.invalidate()
        undoTimer = nil
        mostrarUndo = false
        viewModel.limpiarUltimoPedidoEliminado()
    }

    private var headerCEO: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
                AvatarCirculo(iniciales: "RC", color: AppColor.ceo, tamano: 54)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Renzo Campos")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Text("CEO · Pedidos y requerimientos")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
                Spacer()
            }

            TarjetaGlass(tint: AppColor.ceo.opacity(0.4)) {
                HStack {
                    Label("\(viewModel.pedidosPendientes.count) pendientes", systemImage: "tray.full.fill")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColor.textoPrincipal)
                    Spacer()
                    Image(systemName: "crown.fill")
                        .foregroundColor(AppColor.ceo)
                }
            }
        }
    }

    private var listaPendientes: some View {
        VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Por atender",
                          subtitulo: viewModel.pedidosPendientes.isEmpty ? "Sin pedidos pendientes" : "Toca para marcar como atendido",
                          color: AppColor.ceo)

            if viewModel.pedidosPendientes.isEmpty {
                TarjetaGlass {
                    Text("No hay pedidos ni requerimientos pendientes. ✨")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColor.textoSecundario)
                }
            } else {
                ForEach(viewModel.pedidosPendientes) { pedido in
                    CardPedido(pedido: pedido) {
                        viewModel.alternarCompletado(pedido)
                    } onEliminar: {
                        viewModel.eliminarPedido(pedido)
                        iniciarUndo()
                    }
                }
            }
        }
    }

    private var listaCompletados: some View {
        let completados = viewModel.store.pedidos.filter { $0.estaCompletado }
        return VStack(alignment: .leading, spacing: 12) {
            TituloSeccion(titulo: "Atendidos",
                          subtitulo: "Requerimientos ya resueltos",
                          color: AppColor.consumo)

            if completados.isEmpty {
                EmptyView()
            } else {
                ForEach(completados) { pedido in
                    CardPedido(pedido: pedido) {
                        viewModel.alternarCompletado(pedido)
                    } onEliminar: {
                        viewModel.eliminarPedido(pedido)
                        iniciarUndo()
                    }
                }
            }
        }
    }
}

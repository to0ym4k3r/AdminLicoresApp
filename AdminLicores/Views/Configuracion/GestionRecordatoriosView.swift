import SwiftUI

/// Gestión de recordatorios: ver todos, crear personalizados y eliminar.
struct GestionRecordatoriosView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var mostrarNuevo = false

    var body: some View {
        ZStack {
            AppColor.fondoDegradado.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    explicacion
                    lista
                }
                .padding(20)
            }
        }
        .navigationTitle("Mis recordatorios")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { mostrarNuevo = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarNuevo) {
            NuevoRecordatorioSheet()
        }
    }

    private var explicacion: some View {
        TarjetaGlass(tint: AppColor.rosaSuave.opacity(0.4)) {
            Text("Los recordatorios se repiten cada semana los días que elijas, y te avisarán con una notificación a la hora programada. Puedes apagarlos con el interruptor. ✨")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(AppColor.textoSecundario)
        }
    }

    private var lista: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.recordatoriosOrdenados) { rec in
                HStack {
                    CardRecordatorio(rec: rec) {
                        viewModel.alternar(rec)
                    }
                    if rec.tipo == .personalizado {
                        Button(role: .destructive) {
                            Task { await NotificationScheduler.shared.cancelar(rec) }
                            withAnimation { viewModel.store.recordatorios.removeAll { $0.id == rec.id } }
                        } label: {
                            Image(systemName: "trash")
                                .font(.body)
                                .foregroundColor(Color(hex: "FF7A8A"))
                        }
                        .buttonStyle(.borderless)
                        .padding(4)
                    }
                }
            }
        }
    }
}

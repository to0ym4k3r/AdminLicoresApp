import SwiftUI

@main
struct AdminLicoresApp: App {
    @StateObject private var viewModel = AppViewModel()
    @State private var permisosSolicitados = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
                .task {
                    // Solicita permisos una sola vez al iniciar para que
                    // los recordatorios puedan notificar.
                    guard !permisosSolicitados else { return }
                    permisosSolicitados = true
                    _ = await NotificationScheduler.shared.solicitarPermiso()
                    await NotificationScheduler.shared.reprogramarTodos(viewModel.store.recordatorios)
                }
        }
    }
}

import SwiftUI

@main
struct AdminLicoresApp: App {
    @StateObject private var viewModel = AppViewModel()
    @State private var permisosSolicitados = false
    @State private var mostrarSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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

                if mostrarSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.3)) { mostrarSplash = false }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}

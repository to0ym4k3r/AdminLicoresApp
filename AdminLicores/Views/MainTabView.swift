import SwiftUI

/// Vista raíz con la barra de pestañas principal de la app.
struct MainTabView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @AppStorage("recorridoGuiadoVisto") private var tourVisto = false
    @State private var mostrarTour = false

    var body: some View {
        TabView {
            RecordatoriosView()
                .tabItem { Label("Hoy", systemImage: "bell.fill") }

            ConsumosView()
                .tabItem { Label("Oficina", systemImage: "cup.and.saucer.fill") }

            PedidosView()
                .tabItem { Label("CEO", systemImage: "crown.fill") }

            ConfigView()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .tint(AppColor.rosaPrincipal)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    mostrarTour = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Ver recorrido guiado")
            }
        }
        .sheet(isPresented: $mostrarTour) {
            TourView {
                tourVisto = true
                mostrarTour = false
            }
        }
        .overlay {
            if !tourVisto {
                TourView {
                    tourVisto = true
                }
                .ignoresSafeArea()
                .zIndex(10)
            }
        }
        .onAppear {
            let apariencia = UITabBarAppearance()
            apariencia.configureWithTransparentBackground()
            apariencia.backgroundColor = UIColor.white.withAlphaComponent(0.65)
            apariencia.backgroundEffect = UIBlurEffect(style: .systemMaterialLight)
            UITabBar.appearance().standardAppearance = apariencia
            UITabBar.appearance().scrollEdgeAppearance = apariencia
        }
    }
}

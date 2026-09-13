import SwiftUI

/// Pantalla de carga mostrada brevemente al abrir la app: fondo, logo,
/// nombre e indicador, con un fade de salida antes de terminar.
struct SplashView: View {
    let onFinish: () -> Void
    @State private var opacidad: Double = 1

    var body: some View {
        ZStack {
            Image("FondoCarga")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(color: .white.opacity(0.6), radius: 12, x: 0, y: 4)

                Text("Admin Licores")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.textoPrincipal)

                ProgressView()
                    .tint(AppColor.rosaPrincipal)
                    .scaleEffect(1.2)
                    .padding(.top, 6)
            }
        }
        .opacity(opacidad)
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation(.easeOut(duration: 0.35)) { opacidad = 0 }
            try? await Task.sleep(nanoseconds: 400_000_000)
            onFinish()
        }
    }
}
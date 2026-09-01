import Foundation
import Combine

/// Almacén central de datos persistidos en JSON sobre UserDefaults.
/// Se eligió esta estrategia para datos locales ligeros (listas pequeñas),
/// con codificación mediante Codable: simple, ligera y sin migraciones.
@MainActor
final class AppStore: ObservableObject {

    // MARK: - Datos publicados
    @Published var recordatorios: [Recordatorio] = [] {
        didSet { guardar() }
    }
    @Published var miembros: [MiembroOficina] = [] {
        didSet { guardar() }
    }
    @Published var consumos: [Consumo] = [] {
        didSet { guardar() }
    }
    @Published var productos: [ProductoConsumo] = [] {
        didSet { guardar() }
    }
    @Published var pedidos: [PedidoRequerimiento] = [] {
        didSet { guardar() }
    }
    @Published var proveedores: [String] = [] {
        didSet { guardar() }
    }
    @Published var vendedores: [Vendedor] = [] {
        didSet { guardar() }
    }

    // MARK: - Persistencia
    private let defaults = UserDefaults.standard
    private enum Key: String {
        case recordatorios, miembros, consumos, productos, pedidos, proveedores, vendedores
    }

    init() {
        cargar()
        if recordatorios.isEmpty { seedRecordatorios() }
        if miembros.isEmpty { seedMiembros() }
        if productos.isEmpty { seedProductos() }
        if vendedores.isEmpty { seedVendedores() }
    }

    private func cargar() {
        recordatorios = load([Recordatorio].self, for: .recordatorios) ?? []
        miembros = load([MiembroOficina].self, for: .miembros) ?? []
        consumos = load([Consumo].self, for: .consumos) ?? []
        productos = load([ProductoConsumo].self, for: .productos) ?? []
        pedidos = load([PedidoRequerimiento].self, for: .pedidos) ?? []
        proveedores = load([String].self, for: .proveedores) ?? []
        vendedores = load([Vendedor].self, for: .vendedores) ?? []
    }

    private func load<T: Decodable>(_ type: T.Type, for key: Key) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func guardar() {
        save(recordatorios, for: .recordatorios)
        save(miembros, for: .miembros)
        save(consumos, for: .consumos)
        save(productos, for: .productos)
        save(pedidos, for: .pedidos)
        save(proveedores, for: .proveedores)
        save(vendedores, for: .vendedores)
    }

    private func save<T: Encodable>(_ value: T, for key: Key) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }

    // MARK: - Datos de ejemplo iniciales (seed)

    private func seedRecordatorios() {
        let cal = Calendar.current
        func hora(_ h: Int, _ m: Int) -> Date {
            cal.date(bySettingHour: h, minute: m, second: 0, of: Date())!
        }
        // 1. Avances de proveedores: lunes, martes y miércoles (ISO: 1,2,3)
        recordatorios = [
            Recordatorio(titulo: "Avances a Proveedores",
                         detalle: "Enviar avances de estado a los 3 proveedores habituales.",
                         tipo: .avanceProveedores,
                         diasSemana: [1, 2, 3],
                         hora: hora(9, 0),
                         etiquetaColor: AppColor.proveedores.hexValue),
            Recordatorio(titulo: "Avances por Vendedor",
                         detalle: "Enviar avances de ventas por vendedor.",
                         tipo: .avanceVendedores,
                         diasSemana: [2, 4, 6],
                         hora: hora(18, 0),
                         etiquetaColor: AppColor.vendedores.hexValue),
            Recordatorio(titulo: "Revisar Liquidación de Viáticos",
                         detalle: "Revisar y aprobar liquidaciones de viáticos de todos los lunes.",
                         tipo: .liquidacionViaticos,
                         diasSemana: [1],
                         hora: hora(10, 0),
                         etiquetaColor: AppColor.viaticos.hexValue)
        ]
    }

    private func seedMiembros() {
        miembros = [
            MiembroOficina(nombre: "Renzo Campos", cargo: "CEO", colorIniciales: AppColor.ceo.hexValue),
            MiembroOficina(nombre: "María Fernández", cargo: "Administración", colorIniciales: AppColor.consumo.hexValue),
            MiembroOficina(nombre: "Lucía Torres", cargo: "Contabilidad", colorIniciales: AppColor.vendedores.hexValue)
        ]
    }

    private func seedProductos() {
        productos = [
            ProductoConsumo(nombre: "Café", categoria: "Bebidas", precioUnitario: 12.00),
            ProductoConsumo(nombre: "Agua mineral (botella)", categoria: "Bebidas", precioUnitario: 2.50),
            ProductoConsumo(nombre: "Galletas", categoria: "Miscelánea", precioUnitario: 5.00),
            ProductoConsumo(nombre: "Azúcar (bolsa)", categoria: "Despensa", precioUnitario: 6.50),
            ProductoConsumo(nombre: "Snack 1L", categoria: "Confitería", precioUnitario: 8.00)
        ]
    }

    private func seedVendedores() {
        vendedores = [
            Vendedor(nombre: "Carlos Ramírez", zona: "Norte", telefono: "999 888 777"),
            Vendedor(nombre: "Diana Paredes", zona: "Sur", telefono: "955 444 333")
        ]
    }

    // MARK: - Helpers de proveedores

    /// Los 3 proveedores por defecto (personalizables desde Ajustes)
    var proveedoresPorDefecto: [String] {
        ["Proveedor A", "Proveedor B", "Proveedor C"]
    }
}

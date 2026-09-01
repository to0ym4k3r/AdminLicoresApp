import Foundation

/// Pedido o requerimiento registrado por el CEO (Renzo Campos)
struct PedidoRequerimiento: Identifiable, Codable, Hashable {
    let id: UUID
    var titulo: String
    var descripcion: String
    var prioridad: Prioridad
    var fecha: Date
    var fechaLimite: Date?
    var estaCompletado: Bool

    init(id: UUID = UUID(),
         titulo: String,
         descripcion: String = "",
         prioridad: Prioridad = .media,
         fecha: Date = Date(),
         fechaLimite: Date? = nil,
         estaCompletado: Bool = false) {
        self.id = id
        self.titulo = titulo
        self.descripcion = descripcion
        self.prioridad = prioridad
        self.fecha = fecha
        self.fechaLimite = fechaLimite
        self.estaCompletado = estaCompletado
    }
}

enum Prioridad: String, Codable, CaseIterable, Identifiable {
    case alta = "Alta"
    case media = "Media"
    case baja = "Baja"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .alta: return "FF7A8A"
        case .media: return "FFB86C"
        case .baja: return "8FCB9B"
        }
    }

    var icono: String {
        switch self {
        case .alta: return "exclamationmark.triangle.fill"
        case .media: return "equal.circle.fill"
        case .baja: return "arrow.down.circle.fill"
        }
    }
}

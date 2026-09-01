import Foundation

/// Tipo de recordatorio programado recurrente
enum TipoRecordatorio: String, Codable, CaseIterable, Identifiable {
    case avanceProveedores = "Avances a Proveedores"
    case avanceVendedores = "Avances por Vendedor"
    case liquidacionViaticos = "Revisión de Liquidación de Viáticos"
    case requerimientoCEO = "Pedidos y Requerimientos del CEO"
    case personalizado = "Personalizado"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .avanceProveedores: return "truck.box"
        case .avanceVendedores: return "person.2"
        case .liquidacionViaticos: return "dollarsign.circle"
        case .requerimientoCEO: return "crown"
        case .personalizado: return "bell"
        }
    }
}

/// Un recordatorio programado que se repite ciertos días de la semana
struct Recordatorio: Identifiable, Codable, Hashable {
    let id: UUID
    var titulo: String
    var detalle: String
    var tipo: TipoRecordatorio
    var diasSemana: Set<Int>       // 1 = Lunes ... 7 = Domingo
    var hora: Date                 // solo se usa hora/minuto
    var estaActivado: Bool
    var ultimoDisparo: Date?
    var etiquetaColor: String      // hex para diferenciar visualmente

    init(id: UUID = UUID(),
         titulo: String,
         detalle: String,
         tipo: TipoRecordatorio,
         diasSemana: Set<Int>,
         hora: Date,
         estaActivado: Bool = true,
         ultimoDisparo: Date? = nil,
         etiquetaColor: String = "FFB6C1") {
        self.id = id
        self.titulo = titulo
        self.detalle = detalle
        self.tipo = tipo
        self.diasSemana = diasSemana
        self.hora = hora
        self.estaActivado = estaActivado
        self.ultimoDisparo = ultimoDisparo
        self.etiquetaColor = etiquetaColor
    }

    /// Devuelve los nombres cortos de los días ordenados de lunes a domingo
    var nombreDias: String {
        let nombres = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
        let ordenados = diasSemana.sorted().map { nombres[$0 - 1] }
        return ordenados.joined(separator: " · ")
    }

    /// Días de la semana en los que está activo este recordatorio
    var esHoy: Bool { diasSemana.contains(diaSemanaHoy()) }

    private func diaSemanaHoy() -> Int {
        let cal = Calendar.current
        return cal.component(.weekday, from: Date()) // 1 = Domingo ... 7 = Sábado
    }
}

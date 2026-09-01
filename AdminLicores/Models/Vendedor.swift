import Foundation

/// Vendedor que recibe avances (Mar, Jue, Sáb). Incluye zona y teléfono.
struct Vendedor: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var zona: String
    var telefono: String

    init(id: UUID = UUID(), nombre: String, zona: String = "", telefono: String = "") {
        self.id = id
        self.nombre = nombre
        self.zona = zona
        self.telefono = telefono
    }

    var iniciales: String {
        let partes = nombre.split(separator: " ").prefix(2)
        return partes.map { String($0.prefix(1)) }.joined().uppercased()
    }
}
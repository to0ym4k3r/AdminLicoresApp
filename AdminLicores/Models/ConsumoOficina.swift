import Foundation

/// Miembro del personal de oficina que consume productos del almacén
struct MiembroOficina: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var cargo: String
    var colorIniciales: String   // hex para el avatar

    init(id: UUID = UUID(), nombre: String, cargo: String = "", colorIniciales: String = "FFB6C1") {
        self.id = id
        self.nombre = nombre
        self.cargo = cargo
        self.colorIniciales = colorIniciales
    }

    var iniciales: String {
        let partes = nombre.split(separator: " ").prefix(2)
        return partes.map { String($0.prefix(1)) }.joined().uppercased()
    }
}

/// Producto tomado del almacén consumido en oficina
struct ProductoConsumo: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var categoria: String
    var precioUnitario: Double

    init(id: UUID = UUID(), nombre: String, categoria: String = "", precioUnitario: Double = 0) {
        self.id = id
        self.nombre = nombre
        self.categoria = categoria
        self.precioUnitario = precioUnitario
    }
}

/// Registro individual de consumo: quién, qué, cuánto, cuándo
struct Consumo: Identifiable, Codable, Hashable {
    let id: UUID
    var miembroID: UUID
    var productoID: UUID?
    var nombreProducto: String      // snapshot por si se edita el catálogo
    var cantidad: Int
    var precioUnitario: Double      // snapshot del precio en el momento
    var fecha: Date

    init(id: UUID = UUID(),
         miembroID: UUID,
         productoID: UUID? = nil,
         nombreProducto: String,
         cantidad: Int,
         precioUnitario: Double,
         fecha: Date = Date()) {
        self.id = id
        self.miembroID = miembroID
        self.productoID = productoID
        self.nombreProducto = nombreProducto
        self.cantidad = cantidad
        self.precioUnitario = precioUnitario
        self.fecha = fecha
    }

    var subtotal: Double { Double(cantidad) * precioUnitario }
}

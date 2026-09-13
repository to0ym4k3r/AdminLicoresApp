import Foundation

/// Nota capturada por voz con detección opcional de fecha/hora.
/// Si `fechaDetectada` está en el futuro y `notifID` no es nil, se programó
/// una alarma única (notificación local) identificada por `notifID`.
struct NotaVoz: Identifiable, Codable, Equatable {
    let id: UUID
    var texto: String
    var fechaRegistro: Date
    /// Fecha y hora detectadas en el dictado (nil si no se detectó ninguna).
    var fechaDetectada: Date?
    /// Identificador de la UNNotificationRequest creada, para poder cancelarla.
    var notifID: String?

    init(id: UUID = UUID(),
         texto: String,
         fechaRegistro: Date = Date(),
         fechaDetectada: Date? = nil,
         notifID: String? = nil) {
        self.id = id
        self.texto = texto
        self.fechaRegistro = fechaRegistro
        self.fechaDetectada = fechaDetectada
        self.notifID = notifID
    }
}
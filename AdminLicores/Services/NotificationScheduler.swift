import Foundation
import UserNotifications

/// Administra el registro de notificaciones locales para los recordatorios
/// recurrentes. Cada recordatorio registra notificaciones para cada día
/// de la semana en que debe aparecer.
@MainActor
final class NotificationScheduler {

    static let shared = NotificationScheduler()
    private init() {}

    // MARK: - Permisos

    /// Solicita permiso de notificaciones y refleja el estado actual.
    func solicitarPermiso() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func autorizacionConcedida() async -> Bool {
        (await UNUserNotificationCenter.current()
            .notificationSettings()).authorizationStatus == .authorized
    }

    func notificacionesPendientes() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - Programar

    /// Programa (o recalcula) las notificaciones de un recordatorio.
    /// Estrategia: una notificación por día de la semana con recurrencia semanal,
    /// así se respeta la hora elegida y el usuario puede ver todas las pendientes.
    func programar(_ recordatorio: Recordatorio) async {
        let center = UNUserNotificationCenter.current()
        // Limpiar notificaciones previas de este recordatorio
        let asignadas = await pendientesIds(para: recordatorio.id)
        if !asignadas.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: asignadas)
        }
        guard recordatorio.estaActivado, !recordatorio.diasSemana.isEmpty else { return }

        let horas = Calendar.current.dateComponents([.hour, .minute], from: recordatorio.hora)
        for dia in recordatorio.diasSemana.sorted() {
            var comp = DateComponents()
            comp.hour = horas.hour
            comp.minute = horas.minute
            comp.weekday = weekdayComponent(para: dia) // UNCalendarNotificationTrigger usa 1=Dom

            let contenido = UNMutableNotificationContent()
            contenido.title = recordatorio.titulo
            contenido.body = recordatorio.detalle
            contenido.sound = .default
            contenido.categoryIdentifier = "RECORDATORIO"

            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
            let request = UNNotificationRequest(
                identifier: id(recordatorio.id, dia: dia),
                content: contenido,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func cancelar(_ recordatorio: Recordatorio) async {
        let center = UNUserNotificationCenter.current()
        let asignadas = await pendientesIds(para: recordatorio.id)
        if !asignadas.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: asignadas)
        }
    }

    /// Programa una notificación local única para una fecha determinada.
    /// Se usa para las alarmas de las notas por voz.
    func programarUnaVez(fecha: Date, titulo: String, cuerpo: String, id: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let contenido = UNMutableNotificationContent()
        contenido.title = titulo
        contenido.body = cuerpo
        contenido.sound = .default

        let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: contenido, trigger: trigger)
        try? await center.add(request)
    }

    /// Cancela una notificación local por su identificador (overload genérico,
    /// no rompe la firma existente que recibe un Recordatorio).
    func cancelar(id: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func reprogramarTodos(_ recordatorios: [Recordatorio]) async {
        for r in recordatorios { await programar(r) }
    }

    // MARK: - Helpers

    /// Convierte día ISO (1=Lunes) a componente de Calendar (1=Domingo)
    private func weekdayComponent(para diaISO: Int) -> Int {
        // diaISO: 1=Lun, 7=Dom  →  weekday: 2=Lun, 1=Dom
        if diaISO == 7 { return 1 }
        return diaISO + 1
    }

    private func id(_ recordatorioID: UUID, dia: Int) -> String {
        "rec-\(recordatorioID.uuidString)-dia-\(dia)"
    }

    private func pendientesIds(para recordatorioID: UUID) async -> [String] {
        let pending = await notificacionesPendientes()
        let prefijo = "rec-\(recordatorioID.uuidString)"
        return pending.map(\.identifier).filter { $0.hasPrefix(prefijo) }
    }
}

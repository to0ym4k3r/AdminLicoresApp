import Foundation
import SwiftUI
import Combine

/// ViewModel global que orquesta la lógica de negocio y expone datos
/// derivados a las vistas. Usa el AppStore como fuente de verdad persistida.
@MainActor
final class AppViewModel: ObservableObject {

    @Published private(set) var store: AppStore
    private let scheduler = NotificationScheduler.shared

    /// Reenvía los cambios internos del store al ViewModel: las vistas están
    /// suscritas a `viewModel.objectWillChange`, así que sin este puente las
    /// mutaciones directas (toggle, tachos) no refrescan la UI.
    private var storeCancellable: AnyCancellable?

    init(store: AppStore? = nil) {
        self.store = store ?? AppStore()
        storeCancellable = self.store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    // MARK: - Recordatorios

    var recordatoriosOrdenados: [Recordatorio] {
        store.recordatorios.sorted {
            if $0.tipo.rawValue == $1.tipo.rawValue {
                return $0.hora < $1.hora
            }
            return $0.tipo.rawValue < $1.tipo.rawValue
        }
    }

    func alternar(_ recordatorio: Recordatorio) {
        guard let idx = store.recordatorios.firstIndex(where: { $0.id == recordatorio.id }) else { return }
        var r = store.recordatorios[idx]
        r.estaActivado.toggle()
        store.recordatorios[idx] = r
        Task { await scheduler.programar(r) }
    }

    /// Replaces an existing reminder (same id) and reprograms its notifications.
    func actualizar(_ recordatorio: Recordatorio) {
        guard let idx = store.recordatorios.firstIndex(where: { $0.id == recordatorio.id }) else { return }
        store.recordatorios[idx] = recordatorio
        Task { await scheduler.programar(recordatorio) }
    }

    func horaProxima(recordatorio: Recordatorio) -> Date? {
        let cal = Calendar.current
        let hoy = Date()
        for offset in 0..<14 {
            let candidato = cal.date(byAdding: .day, value: offset, to: hoy)!
            if recordatorio.diasSemana.contains(candidato.weekdayISO) {
                var comp = cal.dateComponents([.year, .month, .day], from: candidato)
                let hora = cal.dateComponents([.hour, .minute], from: recordatorio.hora)
                comp.hour = hora.hour
                comp.minute = hora.minute
                let resultado = cal.date(from: comp)!
                if resultado >= hoy || offset > 0 {
                    return resultado
                }
            }
        }
        return nil
    }

    // MARK: - Consumos de oficina

    /// Consumos del mes actual agrupados por miembro
    var consumosDelMes: [Consumo] {
        let cal = Calendar.current
        let inicioMes = cal.dateInterval(of: .month, for: Date())!.start
        return store.consumos.filter { $0.fecha >= inicioMes }
    }

    func totalConsumoMes() -> Double {
        consumosDelMes.reduce(0) { $0 + $1.subtotal }
    }

    func totalConsumo(miembro: MiembroOficina) -> Double {
        consumosDelMes
            .filter { $0.miembroID == miembro.id }
            .reduce(0) { $0 + $1.subtotal }
    }

    func cantidadConsumos(miembro: MiembroOficina) -> Int {
        consumosDelMes.filter { $0.miembroID == miembro.id }.count
    }

    func consumosDe(miembro: MiembroOficina, enMes mes: Date = Date()) -> [Consumo] {
        let cal = Calendar.current
        guard let intervalo = cal.dateInterval(of: .month, for: mes) else { return [] }
        return store.consumos
            .filter { $0.miembroID == miembro.id && $0.fecha >= intervalo.start && $0.fecha < intervalo.end }
            .sorted { $0.fecha > $1.fecha }
    }

    func registrarConsumo(miembro: MiembroOficina, producto: ProductoConsumo, cantidad: Int) {
        guard cantidad > 0 else { return }
        let consumo = Consumo(
            miembroID: miembro.id,
            productoID: producto.id,
            nombreProducto: producto.nombre,
            cantidad: cantidad,
            precioUnitario: producto.precioUnitario
        )
        store.consumos.append(consumo)
    }

    func eliminarConsumo(_ consumo: Consumo) {
        store.consumos.removeAll { $0.id == consumo.id }
    }

    func agregarMiembro(nombre: String, cargo: String) {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let colores = [AppColor.consumo.hexValue,
                       AppColor.proveedores.hexValue,
                       AppColor.vendedores.hexValue,
                       AppColor.viaticos.hexValue,
                       AppColor.ceo.hexValue]
        let color = colores[store.miembros.count % colores.count]
        store.miembros.append(MiembroOficina(nombre: nombre.trimmingCharacters(in: .whitespaces),
                                             cargo: cargo,
                                             colorIniciales: color))
    }

    func eliminarMiembro(_ miembro: MiembroOficina) {
        store.miembros.removeAll { $0.id == miembro.id }
        store.consumos.removeAll { $0.miembroID == miembro.id }
    }

    func agregarProducto(nombre: String, categoria: String, precio: Double) {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.productos.append(ProductoConsumo(nombre: nombre.trimmingCharacters(in: .whitespaces),
                                               categoria: categoria,
                                               precioUnitario: precio))
    }

    /// Muestra un resumen de los consumos del mes para facturar/descontar a fin de mes.
    func resumenFacturacionMes() -> [MiembroResumen] {
        let cal = Calendar.current
        let inicioMes = cal.dateInterval(of: .month, for: Date())!.start
        let delMes = store.consumos.filter { $0.fecha >= inicioMes }
        return store.miembros.map { miembro in
            let items = delMes.filter { $0.miembroID == miembro.id }
            let total = items.reduce(0) { $0 + $1.subtotal }
            return MiembroResumen(miembro: miembro, total: total, cantidadItems: items.count)
        }
        .sorted { $0.total > $1.total }
        .filter { !( $0.total == 0 && $0.cantidadItems == 0 ) }
    }

    // MARK: - Pedidos / CEO

    var pedidosPendientes: [PedidoRequerimiento] {
        store.pedidos.filter { !$0.estaCompletado }
            .sorted { $0.fecha > $1.fecha }
    }

    func agregarPedido(titulo: String, descripcion: String, prioridad: Prioridad, fechaLimite: Date?) {
        guard !titulo.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.pedidos.append(PedidoRequerimiento(titulo: titulo.trimmingCharacters(in: .whitespaces),
                                                 descripcion: descripcion,
                                                 prioridad: prioridad,
                                                 fechaLimite: fechaLimite))
    }

    /// Crea un pendiente del CEO desde un dictado por voz. El texto completo se
    /// guarda como descripción y un fragmento inicial como título. La fecha
    /// detectada futura se usa como fecha límite.
    func agregarPedidoPorVoz(texto: String, fechaLimite: Date?) {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpio.isEmpty else { return }
        let titulo = String(limpio.prefix(48))
        let limite = fechaLimite ?? nil
        store.pedidos.insert(PedidoRequerimiento(titulo: titulo,
                                                 descripcion: limpio,
                                                 prioridad: .media,
                                                 fechaLimite: (limite != nil && limite! > Date()) ? limite : nil),
                             at: 0)
    }

    func alternarCompletado(_ pedido: PedidoRequerimiento) {
        guard let idx = store.pedidos.firstIndex(where: { $0.id == pedido.id }) else { return }
        store.pedidos[idx].estaCompletado.toggle()
    }

    /// Pedido eliminado más recientemente, para permitir "Deshacer".
    @Published private(set) var ultimoPedidoEliminado: PedidoRequerimiento?

    func eliminarPedido(_ pedido: PedidoRequerimiento) {
        ultimoPedidoEliminado = pedido
        store.pedidos.removeAll { $0.id == pedido.id }
    }

    /// Devuelve a la lista el último pedido eliminado (deshacer).
    func restaurarUltimoPedidoEliminado() {
        guard let pedido = ultimoPedidoEliminado else { return }
        store.pedidos.append(pedido)
        ultimoPedidoEliminado = nil
    }

    /// Limpia la referencia al último pedido eliminado (al expirar el deshacer).
    func limpiarUltimoPedidoEliminado() {
        ultimoPedidoEliminado = nil
    }

    // MARK: - Notas por voz

    /// Registra una nota dictada. Si hay fecha detectada en el futuro, programa
    /// una alarma única (notificación local) y guarda su id para cancelarla.
    func registrarNotaVoz(texto: String, fechaDetectada: Date?) {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpio.isEmpty else { return }

        var nota = NotaVoz(texto: limpio)
        if let fecha = fechaDetectada, fecha > Date() {
            let idNotif = nota.id.uuidString
            nota.fechaDetectada = fecha
            nota.notifID = idNotif
            Task { await scheduler.programarUnaVez(fecha: fecha,
                                                   titulo: "Recordatorio por voz",
                                                   cuerpo: limpio,
                                                   id: idNotif) }
        }
        // Fecha en pasado o ausente: la nota se guarda sin alarma.
        store.notas.insert(nota, at: 0)
    }

    /// Elimina una nota por voz y cancela su notificación pendiente si existe.
    func eliminarNotaVoz(_ nota: NotaVoz) {
        if let idNotif = nota.notifID {
            Task { await scheduler.cancelar(id: idNotif) }
        }
        store.notas.removeAll { $0.id == nota.id }
    }

    /// Devuelve la primera fecha futura razonable detectada en el texto
    /// (o la primera detectada si ninguna está en el futuro).
    func deteccionPara(_ texto: String) -> Date? {
        let fechas = DetectorFecha.fechasEn(texto)
        let horizonte = Date().addingTimeInterval(366 * 24 * 60 * 60)
        if let futura = fechas.first(where: { $0 > Date() && $0 < horizonte }) {
            return futura
        }
        return fechas.first
    }

    // MARK: - Formato moneda

    func moneda(_ valor: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "PEN"
        f.locale = Locale(identifier: "es_PE")
        return f.string(from: NSNumber(value: valor)) ?? "S/ 0.00"
    }
}

/// Resultado de facturación por miembro para el cierre de mes
struct MiembroResumen: Identifiable {
    let miembro: MiembroOficina
    let total: Double
    let cantidadItems: Int
    var id: UUID { miembro.id }
}

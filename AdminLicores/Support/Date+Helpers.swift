import Foundation

extension Date {
    /// Hora/minutiería establecida (ignora día, mes y año)
    var horaMinuto: Date {
        let cal = Calendar.current
        let comp = cal.dateComponents([.hour, .minute], from: self)
        return cal.date(from: comp) ?? self
    }

    /// Formatea hora como "8:30 a. m."
    var horaCorta: String {
        formatter("h:mm a")
    }

    /// Formatea fecha completa legible en español
    var fechaLarga: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateFormat = "EEEE d 'de' MMMM"
        return f.string(from: self)
    }

    var nombreDiaSemana: String {
        formatter("EEEE")
    }

    /// Mes actual como texto: "Agosto"
    var mesActual: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateFormat = "MMMM"
        return f.string(from: self).capitalized
    }

    var esFinDeMes: Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: self)
        let lastDay = cal.date(byAdding: DateComponents(day: 1), to: today)!
        return cal.component(.month, from: lastDay) != cal.component(.month, from: today)
    }

    /// Diferencia de días desde hoy
    var diaNumero: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Día de la semana: 1 = Domingo ... 7 = Sábado
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// Día de la semana estilo ISO: 1 = Lunes ... 7 = Domingo
    var weekdayISO: Int {
        let wd = Calendar.current.component(.weekday, from: self) // 1=Dom
        return wd == 1 ? 7 : wd - 1
    }

    private func formatter(_ formato: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateFormat = formato
        return f.string(from: self)
    }
}

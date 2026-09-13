import Foundation

/// Detecta fechas y horas dentro de texto libre usando NSDataDetector.
/// Soporta formatos absolutos y relativos según el idioma del dispositivo
/// (por ejemplo "el viernes a las 3 pm").
enum DetectorFecha {

    /// Devuelve todas las fechas detectadas en el texto, en el orden en que aparecen.
    static func fechasEn(_ texto: String) -> [Date] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue),
              !texto.isEmpty else {
            return []
        }
        let rango = NSRange(texto.startIndex..<texto.endIndex, in: texto)
        return detector.matches(in: texto, options: [], range: rango)
            .compactMap { $0.date }
    }
}
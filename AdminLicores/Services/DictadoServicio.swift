import Foundation
import Speech
import AVFoundation
import Combine

/// Error de dictado con mensaje amigable para mostrar al usuario.
enum DictadoError: LocalizedError {
    case reconocedorNoDisponible

    var errorDescription: String? {
        switch self {
        case .reconocedorNoDisponible:
            return "El reconocimiento de voz no está disponible en este dispositivo."
        }
    }
}

/// Servicio de dictado por voz (es-PE): graba con el micrófono, reconoce el
/// habla en tiempo real y expone el texto parcial y final.
@MainActor
final class DictadoServicio: NSObject, ObservableObject {

    @Published var textoParcial: String = ""
    @Published var estaGrabando: Bool = false
    @Published var errorMensaje: String?

    private let reconocedor: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var textoFinal: String = ""

    override init() {
        reconocedor = SFSpeechRecognizer(locale: Locale(identifier: "es-PE"))
        super.init()
    }

    // MARK: - Permisos

    /// Solicita permiso de reconocimiento de voz y de micrófono.
    /// Compatible con iOS 16 (usa AVAudioSession en lugar de AVAudioApplication).
    func solicitarPermiso() async -> Bool {
        let permisoHabla = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { estado in
                continuation.resume(returning: estado == .authorized)
            }
        }

        // Configurar la sesión antes de pedir el micrófono evita el error
        // de categoría no compatible con grabación (OSStatus 561015905).
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        let permisoMicrofono = await withCheckedContinuation { continuation in
            session.requestRecordPermission { concedido in
                continuation.resume(returning: concedido)
            }
        }

        return permisoHabla && permisoMicrofono
    }

    // MARK: - Grabación

    /// Inicia la grabación y el reconocimiento de voz en tiempo real.
    func iniciar() throws {
        guard let reconocedor = reconocedor, reconocedor.isAvailable else {
            throw DictadoError.reconocedorNoDisponible
        }

        // Limpia cualquier sesión previa antes de empezar una nueva.
        detener()
        textoParcial = ""
        textoFinal = ""
        errorMensaje = nil

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let node = audioEngine.inputNode
        let formato = node.outputFormat(forBus: 0)

        let nuevaRequest = SFSpeechAudioBufferRecognitionRequest()
        nuevaRequest.shouldReportPartialResults = true
        nuevaRequest.taskHint = .dictation
        request = nuevaRequest

        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: formato) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = reconocedor.recognitionTask(with: nuevaRequest) { [weak self] resultado, error in
            // El callback llega en una cola arbitraria: saltamos al main.
            DispatchQueue.main.async {
                guard let self else { return }
                if let resultado {
                    self.textoParcial = resultado.bestTranscription.formattedString
                    self.textoFinal = resultado.bestTranscription.formattedString
                }
                if let error {
                    self.errorMensaje = "No se pudo reconocer el audio. Intenta de nuevo."
                } else if resultado?.isFinal == true {
                    self.detener()
                }
            }
        }

        estaGrabando = true
    }

    /// Detiene la grabación y devuelve el texto final reconocido.
    @discardableResult
    func detener() -> String {
        let final = textoFinal.isEmpty ? textoParcial : textoFinal
        detenerInterno()
        estaGrabando = false
        return final
    }

    // MARK: - Limpieza

    private func detenerInterno() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
//
//  CoverImageLoader.swift
//  AJBooks
//
//  Descarga y guarda en caché las portadas de Open Library.
//
//

import UIKit

@MainActor
final class CoverImageLoader {

    static let shared = CoverImageLoader()

    /// Caché en memoria: la misma portada no se descarga dos veces por sesión
    private let memoryCache = NSCache<NSURL, UIImage>()
    /// Descargas en curso: si dos vistas piden la misma portada, comparten la petición
    private var inFlight: [URL: Task<UIImage, Error>] = [:]
    private let session: URLSession
    private let maxAttempts = 2

    init() {
        let configuration = URLSessionConfiguration.default
        // Caché en disco para que las portadas sigan disponibles entre aperturas
        configuration.urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                                          diskCapacity: 150 * 1024 * 1024)
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 20
        session = URLSession(configuration: configuration)
        memoryCache.countLimit = 300
    }

    /// Imagen ya descargada, sin esperar
    func cachedImage(for url: URL) -> UIImage? {
        memoryCache.object(forKey: url as NSURL)
    }

    func image(for url: URL) async throws -> UIImage {
        if let cached = cachedImage(for: url) { return cached }
        if let running = inFlight[url] { return try await running.value }

        // Tarea independiente: si la vista que la pidió desaparece, la descarga continúa y queda en caché para la próxima vez
        let task = Task { [session, maxAttempts] in
            try await Self.download(url, session: session, attempts: maxAttempts)
        }
        inFlight[url] = task
        defer { inFlight[url] = nil }

        let image = try await task.value
        memoryCache.setObject(image, forKey: url as NSURL)
        return image
    }

    private nonisolated static func download(_ url: URL, session: URLSession, attempts: Int) async throws -> UIImage {
        var lastError: Error = URLError(.unknown)
        for attempt in 1...attempts {
            do {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                      let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            } catch {
                lastError = error
                if attempt < attempts {
                    try? await Task.sleep(for: .milliseconds(600))
                }
            }
        }
        throw lastError
    }
}

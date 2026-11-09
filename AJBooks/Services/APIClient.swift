//
//  APIClient.swift
//  AJBooks
//  Created by Jolette Rivera on 08/11/26.
//


import Foundation

protocol APIClientProtocol {
    func get<T: Decodable>(
        from url: URL
    ) async throws -> T
}

final class APIClient: APIClientProtocol {

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
        case connectivity(URLError.Code)
        case decoding

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "La dirección del servicio no es válida."
            case .invalidResponse:
                return "El servidor devolvió una respuesta no válida."
            case .httpError(let statusCode):
                return "El servidor respondió con un error (código \(statusCode))."
            case .connectivity:
                return "No hay conexión con el servidor. Revisa tu internet."
            case .decoding:
                return "No se pudo interpretar la respuesta del servidor."
            }
        }
    }

    enum RequestMethod: String {
        case get = "GET"
        case put = "PUT"
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(
        from url: URL
    ) async throws -> T {

        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.get.rawValue
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            // Una tarea cancelada (cambio de pestaña) no es un error para el usuario.
            if urlError.code == .cancelled { throw CancellationError() }
            throw APIError.connectivity(urlError.code)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error de decodificación:", error)
            throw APIError.decoding
        }
    }
}

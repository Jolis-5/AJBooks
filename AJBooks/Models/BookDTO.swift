//
//  BookDTO.swift
//  AJBooks
//

import Foundation

struct BookSearchResponseDTO: Decodable, Sendable {
    let docs: [BookDTO]
}

/// Copia de cada libro que devuelve search.json.
/// Todo lo que Open Library puede omitir es opcional; Swift genera el decodificador automáticamente
/// (decodeIfPresent para los opcionales) y los valores de respaldo se ponen al convertir a Book.
struct BookDTO: Decodable, Sendable {
    let key: String
    let title: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let firstSentence: FlexibleText?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case firstSentence = "first_sentence"
    }
}

/// Respuesta del endpoint
struct WorkDetailDTO: Decodable, Sendable {
    let description: FlexibleText?
}

/// Open Library entrega algunos textos de tres formas distintas:
/// "texto", ["texto"] o {"type": "...", "value": "texto"}.
/// Es el único init(from:) escrito a mano porque el automático solo acepta una forma.
struct FlexibleText: Decodable, Sendable {
    let text: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            text = string
        } else if let strings = try? container.decode([String].self) {
            text = strings.first
        } else if let object = try? container.decode(ValueObject.self) {
            text = object.value
        } else {
            text = nil
        }
    }

    /// Texto sin espacios sobrantes, nil si queda vacío
    var cleanedText: String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else { return nil }
        return trimmed
    }

    private struct ValueObject: Decodable {
        let value: String
    }
}

extension Book {
    /// El "key" de Open Library es el id estable del libro
    init(from dto: BookDTO) {
        let authors = (dto.authorName ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let title = (dto.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        self.init(
            id: dto.key,
            title: title.isEmpty ? "Sin título" : title,
            author: authors.first ?? "Autor desconocido",
            coverID: dto.coverI,
            summary: dto.firstSentence?.cleanedText,
            authors: authors,
            firstPublishYear: dto.firstPublishYear
        )
    }
}

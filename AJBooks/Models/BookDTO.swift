//
//  BookDTO.swift
//  AJBooks
//

import Foundation

struct BookSearchResponseDTO: Decodable, Sendable {
    let docs: [BookDTO]
}

struct BookDTO: Decodable, Sendable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    var coverI: Int? = nil
    var firstSentence: FlexibleText? = nil

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case firstSentence = "first_sentence"
    }
}

extension BookDTO {
    /// Open Library a veces omite campos
    /// Si falta el título se usa un texto de respaldo en lugar de descartar toda la respuesta
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? "Sin título"
        authorName = try? container.decodeIfPresent([String].self, forKey: .authorName)
        firstPublishYear = try? container.decodeIfPresent(Int.self, forKey: .firstPublishYear)
        coverI = try? container.decodeIfPresent(Int.self, forKey: .coverI)
        firstSentence = try? container.decodeIfPresent(FlexibleText.self, forKey: .firstSentence)
    }
}

/// Respuesta del endpoint
struct WorkDetailDTO: Decodable, Sendable {
    var description: FlexibleText? = nil
}

/// Open Library entrega algunos textos como String
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
        let title = dto.title.trimmingCharacters(in: .whitespacesAndNewlines)

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

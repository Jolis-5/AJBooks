//
//  Theme.swift
//  AJBooks
//
//  Paleta de colores, tipografía y estilos reutilizables de la app.
//

import SwiftUI
import UIKit

// MARK: - Paleta

enum AppColors {

    /// Vino profundo: títulos, barra de pestañas, botones principales
    static let wine = Color(light: 0x5B1A2A, dark: 0xE7B7B9)
    /// Burdeos: degradados y acentos secundarios
    static let burgundy = Color(light: 0x7D2537, dark: 0xC98A92)
    /// Rojo ladrillo: favoritos, acciones destructivas
    static let red = Color(light: 0xB23A48, dark: 0xE06B78)
    /// Dusty pink: chips seleccionados, fondos suaves, portadas de respaldo
    static let dustyPink = Color(light: 0xD8A7A7, dark: 0x7A4A52)
    /// Sand: bordes, separadores, insignias
    static let sand = Color(light: 0xD9C4A0, dark: 0x5E5141)
    /// Creme: fondo general de las pantallas
    static let creme = Color(light: 0xF7F0E3, dark: 0x1C1416)
    /// Blanco "papel": superficie de tarjetas
    static let paper = Color(light: 0xFFFDF9, dark: 0x2A1F22)

    /// Texto principal (tinta) y secundario
    static let ink = Color(light: 0x2B1418, dark: 0xF7EDE6)
    static let inkSecondary = Color(light: 0x7A5F62, dark: 0xC9B4B0)

    /// Fondo de pantalla con un ligero degradado creme → sand
    static let screenBackground = LinearGradient(
        colors: [creme, creme, sand.opacity(0.35)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Degradado principal (bienvenida, portadas sin imagen)
    static let wineGradient = LinearGradient(
        colors: [wine, burgundy],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    /// Color dinámico que cambia entre modo claro y oscuro
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Tipografía
//
// - Títulos: New York (serif del sistema), clásica y editorial, ideal para libros
// - Texto: SF Pro, moderna y muy legible en tamaños pequeños
// - Etiquetas: SF Pro en mayúsculas con espaciado, estilo "lomo de libro"
// Todas respetan Dynamic Type porque parten de estilos de texto del sistema

enum AppFonts {
    /// Logotipo de la bienvenida.
    static let brand = Font.system(size: 56, weight: .bold, design: .serif)
    /// Títulos grandes de cada pantalla
    static let screenTitle = Font.system(.largeTitle, design: .serif).weight(.bold)
    /// Título de un libro en el detalle
    static let bookTitle = Font.system(.title, design: .serif).weight(.semibold)
    /// Encabezados de sección
    static let sectionTitle = Font.system(.title3, design: .serif).weight(.semibold)
    /// Título de un libro en una tarjeta
    static let cardTitle = Font.system(.headline, design: .serif)
    /// Autor y datos secundarios
    static let author = Font.system(.subheadline, design: .default).weight(.medium)
    /// Texto de lectura (descripciones)
    static let body = Font.system(.body, design: .serif)
    /// Texto pequeño
    static let caption = Font.system(.caption, design: .default)
    /// Etiquetas en mayúsculas (año, contadores)
    static let overline = Font.system(.caption2, design: .default).weight(.semibold)
}

// MARK: - Estilos reutilizables

/// Botón principal: cápsula vino con texto blanco
struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = AppColors.wine

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(tint, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Botón secundario: contorno vino sobre papel
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif))
            .foregroundStyle(AppColors.wine)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(AppColors.paper, in: Capsule())
            .overlay(Capsule().strokeBorder(AppColors.wine, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

/// Superficie de tarjeta: papel, esquinas redondeadas y sombra suave
struct CardBackground: ViewModifier {
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(AppColors.paper, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppColors.sand.opacity(0.6), lineWidth: 0.5)
            )
            .shadow(color: AppColors.wine.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

/// Fondo creme de pantalla completa
struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.screenBackground.ignoresSafeArea())
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 18) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius))
    }

    func screenBackground() -> some View {
        modifier(ScreenBackground())
    }
}

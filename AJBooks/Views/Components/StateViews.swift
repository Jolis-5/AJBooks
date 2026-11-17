//
//  StateViews.swift
//  AJBooks
//
//  Vistas reutilizables para los estados de pantalla: cargando, error, sin resultados y lista vacía.
//

import SwiftUI

/// Encabezado común de cada pantalla principal
struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow)
                .font(AppFonts.overline)
                .textCase(.uppercase)
                .tracking(1.6)
                .foregroundStyle(AppColors.red)

            Text(title)
                .font(AppFonts.screenTitle)
                .foregroundStyle(AppColors.wine)
                .accessibilityAddTraits(.isHeader)

            if let subtitle {
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.inkSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

/// Estado de carga
struct LoadingStateView: View {
    var message: String = "Cargando libros..."

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.wine)
            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.inkSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

/// Estado de error con botón para reintentar
struct ErrorStateView: View {
    var title: String = "No se pudo cargar"
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title).font(AppFonts.sectionTitle).foregroundStyle(AppColors.wine)
            } icon: {
                Image(systemName: "wifi.exclamationmark").foregroundStyle(AppColors.red)
            }
        } description: {
            Text(message)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.inkSecondary)
        } actions: {
            Button("Reintentar", systemImage: "arrow.clockwise", action: retry)
                .buttonStyle(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Estado vacío / sin resultados con acción opcional
struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title).font(AppFonts.sectionTitle).foregroundStyle(AppColors.wine)
            } icon: {
                Image(systemName: systemImage).foregroundStyle(AppColors.dustyPink)
            }
        } description: {
            Text(message)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.inkSecondary)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Chip seleccionable (categorías y sugerencias)
struct ChipView: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? AppColors.creme : AppColors.wine)
                .background(isSelected ? AppColors.wine : AppColors.paper, in: Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? .clear : AppColors.dustyPink, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Estados") {
    TabView {
        LoadingStateView().tabItem { Text("Loading") }
        ErrorStateView(message: "No hay conexión.") {}.tabItem { Text("Error") }
        EmptyStateView(title: "Sin resultados", systemImage: "magnifyingglass",
                       message: "Prueba con otro título.").tabItem { Text("Vacío") }
    }
    .screenBackground()
}

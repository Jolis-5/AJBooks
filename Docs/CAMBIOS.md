# Registro de cambios

## Reorganización de carpetas
- Se agruparon los archivos por tipo: `App/`, `Models/`, `Stores/` y `Views/`.
- Dentro de `Views/` hay una subcarpeta por pantalla (`Welcome`, `Home`, `Search`, `Favorites`, `Filter`, `Navigation`) y `Components/` para vistas reutilizables.

## Favoritos
- `Libro`: modelo con `id`, `title` y `author`.
- `FavoritesStore`: guarda los favoritos en memoria y los comparte entre vistas.
- `TarjetaLibroView`: tarjeta con botón de corazón para agregar o quitar un libro de favoritos.


## Práctica 8: interfaz, flujos completos y MVP
- **Tema visual** (`Theme/Theme.swift`): paleta vino, burdeos, rojo, dusty pink, sand, creme y blanco papel con soporte para modo oscuro; tipografía New York (títulos) + SF Pro (texto); estilos de botón, tarjeta y fondo reutilizables. `AccentColor` ahora es vino.
- **Buscar** ahora consulta Open Library con `BookSearchViewModel` (nuevo): espera mientras escribes, estados inicial, cargando, resultados, sin resultados y error con reintento.
- **Book** agrega `authors` y `firstPublishYear`; `SavedBook` también los guarda
- **Detalle**: muestra autores, año, botón Guardar/Eliminar, ficha y enlace para compartir.
- **Mis libros**: contador, filtro local, eliminar con confirmación, estado vacío con acceso a Buscar y contador en la pestaña.
- **Explorar**: las categorías ya usan temas reales de Open Library en lugar de datos fijos (antes los ids cambiaban y no se podían quitar de favoritos).
- **Portada**: estado “Sin portada” con diseño propio.
- **Errores**: `FavoritesStore` hace rollback y expone `errorMessage` (se muestra en una alerta); la app ya no se cierra si SwiftData falla, `BookDTO` acepta libros sin título.
- **Pruebas**: 42 pruebas pasan
- **Portadas en Mis libros**: `AsyncImage` marcaba como error las descargas canceladas dentro de grids "lazy" y ya no reintentaba, por eso libros con portada aparecían como "Sin portada". Se reemplazó por `CoverImageLoader` (caché en memoria y en disco, reintento y descargas compartidas). "Sin portada" ahora solo aparece si Open Library no tiene portada, si la descarga falla se muestra "Portada no disponible" y se reintenta al volver a la pantalla.

## Práctica 8: preparación de la entrega final
- **README** Descripción, funcionalidades, tecnologías, requisitos, instalación, ejecución, servicios externos e integrantes.
- **Docs/ARQUITECTURA.md**: arquitectura, networking (endpoints y modelos), persistencia, decisiones técnicas, pruebas y limitaciones.
- **Docs/ENTREGA.md**: revisión del repositorio, pruebas ejecutadas, verificación funcional y versión de entrega.
- **Docs/screenshots/**: 11 capturas de la app funcionando.
- **Limpieza**: fuera del repositorio `.DS_Store` y `xcuserdata/`; `.gitignore` ampliado, se eliminó `Docs/README.md`.

## Correcciones de la revisión del profesor
- **Sin `try!` al crear la base de datos** (`AJBooksApp`): se intenta en disco, luego en memoria y, si ambos fallan, se muestra una pantalla de error en lugar de cerrar la app.
- **`BookDTO` más simple**: todas las propiedades son `let`, sin valores por defecto; `title` es opcional y se usa el decodificador automático. El único `init(from:)` escrito a mano es el de `FlexibleText`.
- **Sin singleton en `CoverImageLoader`**: se quitó `shared`; `AJBooksApp` crea la instancia y la inyecta con `.environment(\.coverImageLoader, ...)`.
- **`FavoritesStore` como servicio**: ya no es `@Observable` ni guarda `errorMessage`; `fetchAll`, `add` y `remove` lanzan errores (`throws`) en lugar de devolver `Bool` con `@discardableResult`, y `fetchSaved` ya no oculta errores con `try?`.
- **Nuevo `FavoritesViewModel`**: guarda la lista compartida de Mis libros y maneja los errores del servicio.
- **README**: versión de Swift y de macOS más claras.

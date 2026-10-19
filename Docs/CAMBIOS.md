# Registro de cambios

## Reorganización de carpetas
- Se agruparon los archivos por tipo: `App/`, `Models/`, `Stores/` y `Views/`.
- Dentro de `Views/` hay una subcarpeta por pantalla (`Welcome`, `Home`, `Search`, `Favorites`, `Filter`, `Navigation`) y `Components/` para vistas reutilizables.
- Se unificaron los nombres de archivos en inglés (`FavoritesView`, `FilterCategoryView`, `SearchBooksView`, `FavoritesStore`).

## Favoritos
- `Libro`: modelo con `id`, `title` y `author`.
- `FavoritesStore`: guarda los favoritos en memoria y los comparte entre vistas.
- `TarjetaLibroView`: tarjeta con botón de corazón para agregar o quitar un libro de favoritos.


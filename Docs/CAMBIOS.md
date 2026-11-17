#DOCUMENTACIÓN

## Reorganización de carpetas
- Se agruparon los archivos por tipo: `App/`, `Models/`, `Stores/` y `Views/`.
- Dentro de `Views/` hay una subcarpeta por pantalla (`Welcome`, `Home`, `Search`, `Favorites`, `Filter`, `Navigation`) y `Components/` para vistas reutilizables.
## Problemas encontrados
- Todos los archivos estaban juntos en la raíz del proyecto, sin separar modelos, vistas y lógica compartida.
- Los nombres de archivos mezclaban español e inglés (`BusquedaLibroView`, `FavoritosView`, `FiltroCategoriaView`), y algunos no coincidían con lo que contenían (`BookCardFavoritesView.swift` contiene `TarjetaLibroView`). **(confirma si ya lo renombraste)**
- El repositorio estaba rastreando archivos personales de Xcode y macOS (`.DS_Store`, `xcuserdata/`), que cambian en cada equipo y generan conflictos.

## Cambios realizados
- Organicé el proyecto en carpetas:
  - `App/`: punto de entrada (`AJBooksApp`, `RootView`).
  - `Models/`: datos (`Libro`, `Item`).
  - `Stores/`: estado compartido (`FavoritesStore`).
  - `Views/`: una subcarpeta por pantalla (`Welcome`, `Home`, `Search`, `Favorites`, `Filter`, `Navigation`) y `Components/` para vistas reutilizables (`BookCardView`, tarjeta de libro).
- Unifiqué los nombres de los archivos en inglés. **(confirma)**
- Agregué `.gitignore` y dejé de rastrear `.DS_Store` y `xcuserdata/`.
- Separé el estado de favoritos de las vistas: vive en `FavoritesStore`, y las vistas solo lo consultan y lo modifican.


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
## Decisiones de arquitectura
- Dejé creada la separación entre datos (`Models`), estado compartido (`Stores`) y presentación (`Views`). Esa separación es la base de MVVM: cuando se implemente, la lógica que hoy vive en el Store pasará a ViewModels sin tocar la estructura de las vistas.
- Las vistas se agrupan por pantalla, así cada ViewModel futuro corresponde a una carpeta de `Views/`.
- Reservé `Services/` (llamadas a Open Library) y `Persistence/` (base de datos) para cuando se agreguen, en vez de mezclarlos con las vistas.


## Pendientes
- Implementar MVVM: crear los ViewModels y mover ahí la lógica que hoy está en las vistas y en el Store.
- Conectar Open Library mediante una capa de `Services/`.
- Hacer persistentes los favoritos con una base de datos (hoy se guardan solo en memoria).

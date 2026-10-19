#DOCUMENTACIÓN

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

## Decisiones de arquitectura
- Dejé creada la separación entre datos (`Models`), estado compartido (`Stores`) y presentación (`Views`). Esa separación es la base de MVVM: cuando se implemente, la lógica que hoy vive en el Store pasará a ViewModels sin tocar la estructura de las vistas.
- Las vistas se agrupan por pantalla, así cada ViewModel futuro corresponde a una carpeta de `Views/`.
- Reservé `Services/` (llamadas a Open Library) y `Persistence/` (base de datos) para cuando se agreguen, en vez de mezclarlos con las vistas.


## Pendientes
- Implementar MVVM: crear los ViewModels y mover ahí la lógica que hoy está en las vistas y en el Store.
- Conectar Open Library mediante una capa de `Services/`.
- Hacer persistentes los favoritos con una base de datos (hoy se guardan solo en memoria).

# Documentación técnica de AJBooks

Este documento explica cómo está construida la app en su versión final (Práctica 8). Todo lo descrito corresponde al código del repositorio

1. [Arquitectura](#1-arquitectura)
2. [Networking](#2-networking)
3. [Persistencia](#3-persistencia)
4. [Decisiones técnicas](#4-decisiones-técnicas)
5. [Pruebas](#5-pruebas)
6. [Limitaciones conocidas](#6-limitaciones-conocidas)

---

## 1. Arquitectura

La app sigue **MVVM** con una capa de servicios para la red y un *store* para la persistencia:

- Las **vistas** solo dibujan un estado y envían acciones, no arman URLs ni hablan con la base de datos.
- Los **ViewModels** convierten las respuestas de la red en estados de pantalla (`loading`, `loaded`, `empty`, `error`).
- **BookService** sabe qué endpoints existen, **APIClient** hace la petición HTTP y traduce los errores.
- **FavoritesStore** es la única pieza que lee y escribe en SwiftData. Se crea una sola vez y se comparte por `@Environment`, así guardar un libro en una pantalla se refleja en todas.

### Estructura de carpetas

```
AJBooks/                              ← raíz del repositorio
├── AJBooks.xcodeproj
├── AJBooks/                          ← código de la app
│   ├── App/
│   │   ├── AJBooksApp.swift          Punto de entrada: crea el ModelContainer y el FavoritesStore
│   │   └── RootView.swift            Decide entre la bienvenida y las pestañas
│   ├── Theme/
│   │   └── Theme.swift               AppColors, AppFonts y estilos (botones, tarjetas, fondo)
│   ├── Models/
│   │   ├── Books.swift               Book: modelo de dominio, portada, búsqueda local, enlace web
│   │   ├── BookDTO.swift             Modelos de respuesta de la API y conversión a Book
│   │   └── SavedBook.swift           @Model de SwiftData
│   ├── Services/
│   │   ├── APIClient.swift           GET genérico + APIError
│   │   ├── BookService.swift         Endpoints de Open Library + MockBookService
│   │   └── CoverImageLoader.swift    Descarga y caché de portadas
│   ├── Stores/
│   │   └── FavoritesStore.swift      Guardar, eliminar y leer libros 
│   ├── Views/
│   │   ├── Welcome/ContentView.swift          Bienvenida
│   │   ├── Navigation/MainTabView.swift       Pestañas + alerta de errores de guardado
│   │   ├── Home/ListBooksView.swift           BookListView (Inicio)
│   │   ├── Search/SearchBooksView.swift       BookSearchView (Buscar) 
│   │   ├── Favorites/FavoritesView.swift      Mis libros
│   │   ├── Filter/FilterCategoryView.swift    CategoryFilterView (Explorar)
│   │   ├── Detail/BookDetailView.swift        Detalle
│   │   └── Components/                        BookCardView, BookCoverView, BookRowView,
│   │                                          BookCardFavoritesView, FavoriteButton, StateViews
│   └── Assets.xcassets
├── ViewModels/
│   ├── BookViewModel.swift           Listas de Inicio y Explorar
│   ├── BookSearchViewModel.swift     Búsqueda
│   └── BookDetailViewModel.swift     Descripción del detalle
├── AJBooksTests/                     Pruebas unitarias
├── AJBooksUITests/                   Prueba de interfaz del recorrido principal
└── Docs/                             Documentación y capturas
```

> La carpeta `ViewModels/` está fuera de `AJBooks/` por cómo se creó en una práctica anterior. Ambas son *carpetas sincronizadas* de Xcode que pertenecen al target **AJBooks**, así que cualquier archivo que se agregue ahí se compila sin tocar el proyecto.

### Responsabilidades

| Componente | Responsabilidad |
| :--- | :--- |
| `AJBooksApp` | Crea el `ModelContainer` (si falla usa uno en memoria) y comparte `FavoritesStore` |
| `RootView` | Muestra la bienvenida y al tocar *Entrar*, las pestañas |
| `MainTabView` | Cuatro pestañas, cada una con su propio `NavigationStack`; muestra la alerta si falla un guardado |
| `BookListView` | Inicio: dibuja los estados de `BookViewModel` y navega al detalle |
| `BookSearchView` | Campo de búsqueda, sugerencias, resultados y navegación al detalle |
| `FavoritesView` | Lista de guardados, filtro local, eliminar con confirmación, estado vacío |
| `CategoryFilterView` | Chips de categoría; un `BookViewModel` por categoría, guardado para no recargar |
| `BookDetailView` | Ficha completa, botón Guardar/Eliminar, compartir, descripción |
| `BookViewModel` | Pide una lista y expone `listStatus` |
| `BookSearchViewModel` | Normaliza el texto, espera 450 ms, busca y descarta respuestas viejas |
| `BookDetailViewModel` | Pide la descripción de la obra, usa el resumen local si no hay |
| `BookService` | Arma las URL de Open Library y devuelve DTOs |
| `APIClient` | Hace el GET, valida el código HTTP y decodifica el JSON |
| `CoverImageLoader` | Descarga portadas una sola vez, las guarda en caché y reintenta |
| `FavoritesStore` | `add`, `remove`, `toggle`, `isFavorite`, `books` y `errorMessage` |
| `Theme` | Colores, fuentes y estilos para que toda la app se vea igual |

### Navegación

| Flujo | Cómo se implementa |
| :--- | :--- |
| Inicio → lista → detalle | `BookListView` + `navigationDestination(item:)` |
| Buscar → resultados → detalle | `BookSearchView` + `navigationDestination(item:)` |
| Mis libros → guardado → detalle | `FavoritesView` + `navigationDestination(item:)` |

---

## 2. Networking

### API utilizada
[Open Library](https://openlibrary.org/developers/api), catálogo abierto del Internet Archive. Es pública, gratuita y **no usa claves**.

### Endpoints

| Uso | Método y URL | Dónde se llama |
| :--- | :--- | :--- |
| Buscar libros (Inicio, Buscar, Explorar) | `GET https://openlibrary.org/search.json?q={texto}&limit=20&fields=key,title,author_name,first_publish_year,cover_i,first_sentence` | `BookService.fetchBooksList(query:)` |
| Descripción de una obra (Detalle) | `GET https://openlibrary.org/works/{id}.json` | `BookService.fetchBookDescription(key:)` |
| Portada | `GET https://covers.openlibrary.org/b/id/{cover_i}-{S\|M\|L}.jpg` | `Book.coverURL(size:)` + `CoverImageLoader` |
| Compartir | `https://openlibrary.org/works/{id}` (solo enlace, no se descarga) | `Book.openLibraryURL` |

El parámetro `fields` pide solo los campos que usa la app, así la respuesta es más ligera.

**Consultas fijas** (`q`):

| Pantalla | Consulta |
| :--- | :--- |
| Inicio | `subject:classic_literature` |
| Explorar | `subject:fiction`, `subject:classic_literature`, `subject:fantasy`, `subject:romance`, `subject:poetry`, `subject:children`, `subject:science`, `subject:history` |
| Buscar | El texto del usuario, sin espacios sobrantes |

### Modelos de respuesta

**Búsqueda** (`BookSearchResponseDTO` → `[BookDTO]`):

```json
{
  "docs": [
    {
      "key": "/works/OL274505W",
      "title": "Cien años de soledad",
      "author_name": ["Gabriel García Márquez"],
      "first_publish_year": 1967,
      "cover_i": 12627383,
      "first_sentence": ["Muitos anos depois, diante do pelotão...", "Molti anni dopo...", "..."]
    }
  ]
}
```

*(Respuesta real recortada. `first_sentence` puede venir en varios idiomas, la app usa la primera.)*

| Campo JSON | Propiedad en `BookDTO` | Uso en `Book` |
| :--- | :--- | :--- |
| `key` | `key` | `id` (identificador estable) |
| `title` | `title` | `title` ("Sin título" si falta) |
| `author_name` | `authorName` | `author` (primero) y `authors` (todos); "Autor desconocido" si falta |
| `first_publish_year` | `firstPublishYear` | `firstPublishYear` |
| `cover_i` | `coverI` | `coverID` |
| `first_sentence` | `firstSentence` | `summary` |

**Obra** (`WorkDetailDTO`): solo se lee `description`, que Open Library entrega de dos formas. `FlexibleText` acepta ambas:

```json
{ "description": "Texto..." }
{ "description": { "type": "/type/text", "value": "Texto..." } }
```

### Manejo de errores

`APIClient.APIError` traduce cada falla a un mensaje en español:

| Caso | Mensaje para el usuario |
| :--- | :--- |
| `invalidURL` | La dirección del servicio no es válida. |
| `invalidResponse` | El servidor devolvió una respuesta no válida. |
| `httpError(statusCode)` | El servidor respondió con un error (código N). |
| `connectivity` | No hay conexión con el servidor. Revisa tu internet. |
| `decoding` | No se pudo interpretar la respuesta del servidor. |

- Una petición **cancelada** (cambiar de pestaña, seguir escribiendo) se convierte en `CancellationError` y no se muestra como error.
- `BookSearchViewModel` ignora una respuesta si mientras tanto el usuario ya buscó otra cosa.
- Cada pantalla con error muestra **Reintentar**.

---

## 3. Persistencia

### Qué se guarda
Solo los **libros guardados** en *Mis libros*, con el modelo `SavedBook` de SwiftData:

| Atributo | Tipo | Notas |
| :--- | :--- | :--- |
| `id` | `String` | `@Attribute(.unique)`, es el `key` de Open Library |
| `title` | `String` | |
| `author` | `String` | Autor principal |
| `coverID` | `Int?` | Para volver a pedir la portada |
| `summary` | `String?` | Primera oración, si existía |
| `savedAt` | `Date` | Ordena la lista (más reciente primero) |
| `authors` | `[String]?` | Agregado en la Práctica 8 |
| `firstPublishYear` | `Int?` | Agregado en la Práctica 8 |

### Mecanismo
- **SwiftData** con el almacén por defecto (`default.store` en *Application Support* del contenedor de la app).
- `AJBooksApp` crea el `ModelContainer`. Si no puede abrirse, usa uno en memoria para que la app no se cierre.
- `FavoritesStore` usa `mainContext`:
  - `add` rechaza ids vacíos y duplicados,
  - `remove` busca por id con un `#Predicate`,
  - después de cada cambio llama a `save()`, si falla, hace `rollback()`, deja un mensaje en `errorMessage` y recarga, así la interfaz siempre coincide con lo guardado.
- El modelo de la vista (`Book`) es independiente de `SavedBook`: se convierten con `SavedBook(book:)` y `asBook`.

---

## 4. Decisiones técnicas

| Decisión | Motivo |
| :--- | :--- |
| **SwiftUI + Observation (`@Observable`)** | Es la forma actual de manejar estado en SwiftUI y evita `ObservableObject`/`@Published` |
| **MVVM con `BookServiceProtocol`** | Separa la interfaz de la red y permite probar los ViewModels con `MockBookService` sin internet |
| **Un `enum` de estado por pantalla** | Una pantalla no puede estar "cargando" y "con error" a la vez, evita estados inconsistentes |
| **`Book` separado de `BookDTO` y `SavedBook`** | Si cambia la API o la base de datos, las vistas no se enteran |
| **SwiftData en lugar de `UserDefaults`** | Los libros son registros con id único y se consultan por id, SwiftData valida la unicidad y migra el esquema |
| **Campos nuevos de `SavedBook` opcionales** | Migración automática sin borrar lo que el usuario ya guardó |
| **Rollback si falla el guardado** | La interfaz nunca muestra un libro como guardado si no lo está |
| **`CoverImageLoader` en lugar de `AsyncImage`** | Dentro de grids *lazy*, `AsyncImage` marcaba como error las descargas canceladas y no reintentaba; los libros aparecían "Sin portada" en *Mis libros* |
| **Espera de 450 ms y mínimo 2 letras al buscar** | Evita una petición por tecla y respeta el uso razonable de la API |
| **Decodificación tolerante en `BookDTO`** | Un libro sin título o sin autor no descarta toda la respuesta |
| **Un `NavigationStack` por pestaña** | Cada flujo conserva su historial al cambiar de pestaña |
| **Un `BookViewModel` por categoría, guardado** | Volver a una categoría no repite la descarga |
| **Sin dependencias externas** | El proyecto se abre y ejecuta sin instalar nada |
| **Aislamiento por defecto en `MainActor`** | Los ViewModels y el store actualizan la interfaz desde el hilo principal sin anotaciones extra |

---

## 5. Limitaciones conocidas

| Limitación | Detalle |
| :--- | :--- |
| **Requiere internet** | Inicio, Buscar y Explorar dependen de Open Library. Sin conexión muestran error con *Reintentar*. |
| **Descripción no disponible sin conexión** | *Mis libros* funciona sin internet, pero la descripción del detalle se pide a la API cada vez y sin conexión muestra error. |
| **Portadas sin conexión** | Solo se ven las portadas que ya estaban en caché, las demás muestran "Portada no disponible". |
| **Portadas lentas** | Algunas portadas se sirven desde archive.org con redirecciones y pueden tardar 20–30 s la primera vez; mientras tanto se ve el indicador de carga. |
| **Sin paginación** | Cada búsqueda o categoría muestra máximo 20 libros. |
| **Calidad de los datos** | Depende de Open Library: títulos en su idioma original, autores faltantes ("Autor desconocido"), años de primera publicación que no siempre coinciden con la edición conocida, descripciones en inglés y una primera oración (`first_sentence`) que puede venir en otro idioma porque la app toma la primera de la lista. |
| **Sin filtros avanzados** | No se puede filtrar por idioma, año o autor exacto, el orden es la relevancia de Open Library. |
| **No se sincroniza** | *Mis libros* vive solo en el dispositivo (sin iCloud ni cuentas). |
| **Solo español** | Los textos están escritos directamente en el código, sin archivos de localización. |
| **Solo iOS 26.5+** | Usa APIs recientes de SwiftUI, por lo que no corre en versiones anteriores. |
| **Firma** | El proyecto trae el equipo de desarrollo de la autora, para un iPhone físico hay que elegir otro (ver README). |
| **Fuera del alcance** | Login, compra, préstamos, integración con Kindle, reseñas sociales y recomendaciones con IA. |

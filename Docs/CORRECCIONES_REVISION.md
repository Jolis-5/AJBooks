# Correcciones de la revisión del profesor

Para cada comentario se indica qué se cambió, en qué archivo y línea, y una explicación corta para responder preguntas.

| # | Comentario | Archivo | ¿Se cambió? |
| :---: | :--- | :--- | :---: |
| 1 | `try!` al crear la base de datos | `AJBooks/App/AJBooksApp.swift` | Sí |
| 2 | Valores por defecto en `BookDTO` | `AJBooks/Models/BookDTO.swift` | Sí |
| 3 | Varios `init(from decoder:)` | `AJBooks/Models/BookDTO.swift` | Sí |
| 4 | Singleton `CoverImageLoader.shared` | `AJBooks/Services/CoverImageLoader.swift` | Sí |
| 5 | ¿Por qué `nonisolated`? | `AJBooks/Services/CoverImageLoader.swift` | Se explica (se mantiene) |
| 6 | ¿Por qué `@discardableResult`? | `AJBooks/Stores/FavoritesStore.swift` | Sí (se eliminó) |
| 7 | `try?` y servicio `@Observable` que maneja sus propios errores | `FavoritesStore.swift` + nuevo `ViewModels/FavoritesViewModel.swift` | Sí |
| 8 | "Swift 5 (modo de lenguaje)" | `README.md` | Sí |
| 9 | Requisito de macOS ambiguo y nombres de vistas viejos | `README.md` | Sí |

---

## 1. `try!` al crear la base de datos

> *"Resolver un error con forzar un try es algo aún peor… si llega a fallar, la app nunca abriría."*

**Antes:** si el almacenamiento en disco fallaba, se intentaba uno en memoria con `try!`. Si ese también fallaba, la app se cerraba al abrirla.

**Ahora** (`AJBooksApp.swift`):

```swift
private static func makeContainer() -> ModelContainer? {        // línea 48
    do {
        return try ModelContainer(for: SavedBook.self)           // 1. en disco
    } catch {
        logger.error(...)
    }
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: SavedBook.self, configurations: config)  // 2. en memoria
    } catch {
        logger.error(...)
        return nil                                               // 3. no se pudo
    }
}
```

- La función devuelve un **opcional** (`ModelContainer?`) en lugar de forzar un resultado.
- En `body` (líneas 28–40): si hay almacenamiento se muestra la app. Si no, se muestra una pantalla con el mensaje *"No se pudo abrir AJBooks"* (`EmptyStateView`).
- Se quitó `.modelContainer(container)` porque ninguna vista usa `@Query` ni `modelContext`. Todo pasa por `FavoritesStore`.

**Cómo explicarlo:** *"Ya no hay `try!` en la app. Cada intento está en su `do/catch`. Si todo falla, el usuario ve un mensaje en lugar de que la app se cierre, y el error queda registrado con `Logger`."*

---

## 2. Valores por defecto en `BookDTO`

> *"¿Por qué poner valores por defecto?"*

**Antes:**

```swift
var coverI: Int? = nil
var firstSentence: FlexibleText? = nil
```

Estaban ahí para que los Previews y las pruebas pudieran crear un `BookDTO` sin escribir esos dos campos. Pero no tenían sentido: el DTO es una **copia de la respuesta de la API** y solo se llena al decodificar el JSON.

**Ahora** (`BookDTO.swift`, líneas 15–21): todas las propiedades son `let`, sin valores por defecto.

```swift
struct BookDTO: Decodable, Sendable {
    let key: String
    let title: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let firstSentence: FlexibleText?
}
```

Los Previews y las pruebas ahora escriben todos los campos, por ejemplo `coverI: nil, firstSentence: nil`.

**Cómo explicarlo:** *"Un DTO representa exactamente lo que manda el servidor, así que es inmutable (`let`) y sin valores inventados. Los campos que Open Library puede omitir son opcionales."*

---

## 3. Varios `init(from decoder:)`

> *"¿Por qué tienen varios init con decoder?"*

**Antes:** `BookDTO` tenía un `init(from decoder:)` escrito a mano que usaba `try?` en cada campo y ponía `"Sin título"` si faltaba el título.

**Ahora:**

- **Se eliminó el de `BookDTO`.** Como `title` ahora es opcional (`String?`), Swift genera el decodificador automáticamente. Para los opcionales usa `decodeIfPresent`, así que si falta un campo queda en `nil` sin romper la respuesta.
- **El valor de respaldo se movió a la conversión** `Book(from:)` (línea 75): `(dto.title ?? "")`, y si queda vacío se usa `"Sin título"`.
- **Solo queda uno escrito a mano: el de `FlexibleText`** (línea 44). Es necesario porque Open Library manda ese texto de tres formas distintas, y el decodificador automático solo acepta una:

```json
"description": "texto"
"description": ["texto"]
"description": { "type": "/type/text", "value": "texto" }
```

**Cómo explicarlo:** *"El DTO usa el `Decodable` automático. Los valores de respaldo se ponen al convertir a `Book`, que es el modelo de la app. El único decoder manual es el de `FlexibleText`, porque ese campo puede venir de tres formas."*

---

## 4. Singleton `CoverImageLoader.shared`

> *"Se recomienda evitar… al no controlar el init, se puede tener varios sin siquiera saber que existe el shared."*

**Antes:** `static let shared = CoverImageLoader()`, y las vistas llamaban a `CoverImageLoader.shared` desde cualquier lugar.

**Ahora** se usa **inyección de dependencias** por el Environment de SwiftUI:

1. **Se crea una sola vez, en un lugar conocido** (`AJBooksApp.swift`, línea 17):
   ```swift
   private let coverLoader = CoverImageLoader()
   ```
2. **Se comparte con las vistas** (línea 31):
   ```swift
   .environment(\.coverImageLoader, coverLoader)
   ```
3. **Se declara la entrada del Environment** (`CoverImageLoader.swift`, línea 86):
   ```swift
   extension EnvironmentValues {
       @Entry var coverImageLoader = CoverImageLoader()   // el valor por defecto solo lo usan los Previews
   }
   ```
4. **La vista la recibe** (`BookCardView.swift`, línea 24):
   ```swift
   @Environment(\.coverImageLoader) private var coverLoader
   ```

**¿Por qué sigue siendo una sola instancia?** Porque guarda la caché de portadas y las descargas en curso. Si cada tarjeta creara la suya, la misma portada se descargaría muchas veces.

**Cómo explicarlo:** *"Quitamos el singleton. La instancia la crea la app y se pasa por el Environment, igual que `FavoritesViewModel`. Así se sabe quién la crea, no se puede usar 'escondida' desde cualquier lugar y en los Previews se puede usar otra."*

---

## 5. ¿Por qué `nonisolated`?

> *"¿Por qué usar un nonisolated?"*

**No se quitó, porque es necesario.** Solo se agregó un comentario que lo explica (`CoverImageLoader.swift`, líneas 57–61).

- La clase es `@MainActor`: todo su código corre en el **hilo principal**, que es donde se dibuja la interfaz.
- `download(...)` descarga los bytes y los convierte en `UIImage`. Eso es **trabajo pesado**.
- Al marcarla como `nonisolated`, esa función **se ejecuta fuera del hilo principal**. Así la interfaz no se traba al hacer scroll por una cuadrícula con muchas portadas.
- Es `static` y recibe todo por parámetro (`url`, `session`, `attempts`) porque, al estar fuera del `MainActor`, **no puede tocar las propiedades de la clase**, como la caché. Cuando termina, `image(for:)`, que sí está en el hilo principal, guarda el resultado en la caché.

**Cómo explicarlo:** *"`nonisolated` saca la descarga y la conversión de la imagen del hilo principal para que la interfaz siga fluida. La caché solo se toca desde el hilo principal, así que no hay problemas de concurrencia."*

---

## 6 y 7. `@discardableResult`, `try?` y el servicio `@Observable`

> *"¿Por qué es discardable?"*
> *"¿Qué pasa si falla? El manejo de errores debería ser chamba del ViewModel que lo llamó… no sabe si puede o no regresar un error."*

**Antes:** `FavoritesStore` hacía tres cosas a la vez:
- guardaba en SwiftData;
- era `@Observable` y guardaba la lista para las vistas;
- atrapaba sus propios errores en `errorMessage`.

Además, `add` y `remove` devolvían `Bool` con `@discardableResult`, y `fetchSaved` usaba `try?`. Por eso, si fallaba, el error se perdía sin aviso.

**Ahora se separó en dos piezas:**

| Pieza | Archivo | Qué hace |
| :--- | :--- | :--- |
| `FavoritesStore` (servicio) | `AJBooks/Stores/FavoritesStore.swift` | Solo habla con SwiftData. **No es `@Observable`**. Sus funciones dicen en la firma que pueden fallar: `fetchAll() throws` (línea 36), `add(_:) throws` (44), `remove(_:) throws` (54), `fetchSaved(id:) throws` (63). Si `save()` falla, hace `rollback()` y **lanza el error** (líneas 71–77). |
| `FavoritesViewModel` (nuevo) | `ViewModels/FavoritesViewModel.swift` | Es `@Observable`. Guarda `books` y `errorMessage`, llama al servicio con `do/catch` y decide qué mensaje mostrar (líneas 37–64). |

```swift
// FavoritesViewModel.swift
func add(_ book: Book) {
    do {
        try store.add(book)          // el servicio puede fallar
        loadBooks()                  // vuelve a leer lo guardado
    } catch {
        errorMessage = "No se pudo guardar «\(book.title)». Intenta de nuevo."
    }
}
```

- **Ya no hay `@discardableResult`.** Las funciones ya no devuelven `Bool`: si algo sale mal, lanzan un error, y el compilador obliga a quien las llama a usar `try`.
- **Ya no hay `try?` en el servicio.** `fetchSaved` usa `throws`, así que un fallo de lectura ya no se confunde con "el libro no existe".
- **Nuevo error propio:** `FavoritesError.invalidBook` (línea 16), que se lanza cuando el libro tiene un id vacío.
- **Las vistas no cambiaron su código.** Solo leen `@Environment(FavoritesViewModel.self)` en lugar de `FavoritesStore.self`. El corazón, el botón del detalle, Mis libros y el contador de la pestaña siguen sincronizados porque comparten el mismo ViewModel.
- MainTabView sigue mostrando la alerta, pero ahora con el `errorMessage` del ViewModel.

**Cómo explicarlo:** *"Separamos responsabilidades. El store es un servicio que solo guarda y avisa con `throws` si falla. El ViewModel lo llama, atrapa el error y decide qué mostrar. Es el mismo patrón que `BookService` y `BookViewModel` para la red."*

**¿Por qué un solo `FavoritesViewModel` para varias pantallas?** Porque "Mis libros" es un estado compartido. Si guardas un libro en el detalle, el corazón de Inicio y el contador de la pestaña deben cambiar al mismo tiempo. Por eso se crea una vez en `AJBooksApp` y se comparte por el Environment.

---

## 8. "Swift 5 (modo de lenguaje)"

> *"¿Modo?"*

**Ahora** (`README.md`, línea 54): `Swift 5 (SWIFT_VERSION = 5.0 en el proyecto, compilado con Xcode 26.6)`.

**Si pregunta qué es el "modo":** Xcode 26.6 trae el compilador de Swift 6.3, pero cada proyecto elige con qué reglas del lenguaje compila, en el ajuste `SWIFT_VERSION`. Este proyecto usa las reglas de **Swift 5**, que son menos estrictas con la concurrencia que las de Swift 6. El código sí usa funciones modernas como `async/await`, `@Observable` y `@MainActor`.

---

## 9. Requisito de macOS ambiguo y nombres viejos

> *"Algo ambiguo, ¿no?"*

- **macOS** (`README.md`, línea 71): se cambió *"Uno que pueda ejecutar Xcode 26"* por **"macOS Tahoe 26 (desarrollado y probado en macOS 26.6)"**.
- **Nombres de vistas:** `BusquedaLibroView`, `FavoritosView` y `FiltroCategoriaView` venían del historial de una práctica anterior y **ya no aparecen en el repositorio**. Los nombres reales son `BookSearchView`, `FavoritesView` y `CategoryFilterView`.

---

## Pruebas

| Suite | Cambio |
| :--- | :--- |
| `FavoritesStoreTests` | Prueban el servicio con `throws`: guardar, no duplicar, id vacío lanza error (`XCTAssertThrowsError`) y eliminar. |
| `FavoritesViewModelTests` (nueva) | `toggle` guarda y quita. Si el servicio falla, aparece `errorMessage` y no se agrega el libro. |
| `BookModelTests` | El orden de guardado se lee con `fetchAll()`. |
| Pruebas que crean `BookDTO` | Ahora escriben todos los campos (`coverI: nil, firstSentence: nil`). |

**Resultado: 44 / 44 pruebas pasan** (43 unitarias + 1 de interfaz).

Comando:

```bash
xcodebuild test -project AJBooks.xcodeproj -scheme AJBooks \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:AJBooksTests \
  -only-testing:AJBooksUITests/AJBooksUITests/testMainNavigationFlow
```

## Documentos actualizados

- `Docs/ARQUITECTURA.md`: responsabilidades, carpeta `ViewModels/` y sección de persistencia.
- `Docs/ENTREGA.md`: tabla de pruebas.
- `Docs/CAMBIOS.md`: sección *"Correcciones de la revisión del profesor"*.

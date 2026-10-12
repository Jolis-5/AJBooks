
## Práctica 4: Navegación y estado compartido

En esta práctica se llevaron a código las decisiones de navegación y de organización del estado definidas en la Práctica 3, y se analizó cómo separar responsabilidades con una propuesta basada en MVVM.

## 1. Conexión entre la bienvenida y el catálogo

### `RootView` 
Se agregó una nueva vista llamada `RootView` que permite decidir qué pantalla mostrar al abrir la app. Mantiene un estado `hasEntered`: mientras es `false` muestra la bienvenida, y cuando cambia a `true` muestra el menú principal. Se usó `@State` (y no un valor persistente) para que la bienvenida aparezca cada vez que se abre la aplicación.

### `ContentView` 
La vista de bienvenida ahora recibe una acción `onEnter`, que se ejecuta al presionar el botón **Entrar**. De esta forma la pantalla solo se encarga de mostrarse, y la decisión de a dónde ir queda en `RootView`.

### `AJBooksApp`
El punto de entrada de la app ahora carga `RootView` en lugar de `ContentView`, y crea el estado compartido de favoritos.

---

## 2. Menú inferior

### `MainTabView`
Se agregó una nueva vista llamada `MainTabView` que permite navegar entre las secciones principales mediante una barra inferior (`TabView`), con cuatro pestañas:

| Pestaña | Vista |
| :--- | :--- |
| Inicio | `ListaLibrosView` |
| Search | `BusquedaLibroView` |
| Saved | `FavoritosView` |
| Filter | `FiltroCategoriaView` |

La pestaña activa se controla con el `enum` `AppTab`. Se nombró `AppTab` y no `Tab` para evitar confusión.

### `FiltroCategoriaView` 
Se agregó una nueva vista llamada `FiltroCategoriaView` que permite filtrar los libros por categoría (Novela, Clásicos, Infantil y Ciencia) mediante botones de selección. La opción **Todas** muestra el catálogo completo. Por ahora utiliza sus propios datos de ejemplo y no está conectada a los favoritos.

---

## 3. Información compartida: favoritos

Para que guardar un libro en una pantalla se refleje en las demás, se creó un único objeto que concentra la lista de favoritos y se comparte con toda la app.

### `Libro` 
Se agregó un nuevo modelo llamado `Libro`, con identificador, título y autor, que permite identificar de forma única cada libro para poder guardarlo. Incluye una lista de libros de ejemplo que sirve como catálogo por lo mientras.

### `FavoritosStore` 
Se agregó una nueva clase observable llamada `FavoritosStore` que permite guardar y consultar los libros favoritos. 

Se crea una sola vez en `AJBooksApp` y se inyecta con `.environment`, de modo que cualquier vista pueda leerlo con `@Environment`.

### `BookCardFavoriteView` 
permite marcar un libro como favorito. Envuelve a `BookCardView` y con un botón de corazón que consulta y modifica `FavoritosStore`.

##Resultado de la práctica " Deberás implementar el flujo principal de navegación de tu MVP y al menos un caso real de información compartida entre vistas."
- Al tocar el corazón en **Inicio**, el libro aparece en **Saved** 
- `FavoritosView` muestra un mensaje cuando la lista está vacía y el total de libros guardados.

---



##SEGUNDA PARTE: Análisis para una propuesta MVVM

MVVM separa la app en tres partes:

- **Model:** los datos (`Libro`).
- **View:** lo que se ve en pantalla (`ListaLibrosView`, `FavoritosView`, etc.).
- **ViewModel:** prepara los datos para una vista y maneja su lógica, sin dibujar nada.



La lógica de la app todavía vive dentro de las vistas. Estas son las responsabilidades que podrían salir de ellas:

| Vista | Responsabilidad actual | Destino propuesto |
| :--- | :--- | :--- |
| `ListaLibrosView` | Lee directamente `Libro.ejemplos` | `ListaLibrosViewModel` / servicio de datos |
| `FiltroCategoriaView` | Guarda la categoría y calcula el filtrado | `FiltroViewModel` |
| `BusquedaLibroView` | Texto de búsqueda y resultados | `BusquedaViewModel` |
| `FavoritosView` | Arma textos derivados y estado vacío | Puede permanecer sin ViewModel |
| `FavoritosStore` | Guarda favoritos | Capa de repositorio (compartida) |



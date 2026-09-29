#Accesibilidad
1. Botón de Favorito / Corazón
   Se implementara porque es un ícono visual sin texto. VoiceOver no sabrá interpretarlo si no le asignas un nombre descriptivo.
   Label: "Agregar a favoritos" (o "Eliminar de favoritos" según el estado activo/inactivo).
   Hint: "Guarda este libro en tu lista personalizada."

2. Botón Cierre / Modal X 
   Se implementara pq  un usuario con lector de pantalla necesita saber cómo salir de una vista emergente o modal.   
   Label: "Cerrar detalles".
   Hint: "Regresa a la lista de resultados de búsqueda."

3. Botón Eliminar / Bote de Basura 
  Al igual que favoritos es un icono visual y es crucial que la voz especifique exactamente qué libro se va a borrar.   
  Label: "Eliminar [Nombre del libro]"
  Hint: "Quita este libro de tu lista de favoritos."

4. Botones de Navegación Inferior 
  se implementara ya que las pestañas o ítems del menú inferior cambian el contexto global de la aplicación.   
  Search Label: "Pestaña Búsqueda".
  Saved Label: "Pestaña Favoritos".
  Filter Label: "Pestaña Filtros".
  Value / State: Indicar cuál está seleccionado actualmente.

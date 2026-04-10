# D-Pad Store - Proyecto Vala/GTK

## Contexto del Proyecto
Interfaz full-screen tipo kiosko para una consola de videojuegos portatil basada en raspberry pi zero 2w con una pantalla cuadrada de 720x720 pixeles.
Es un wrapper visual sobre los scripts de Pi-Apps.

La UI del proyecto debe ser navegable mediante el uso de un Joystick/Gamepad (usando la libreria SDL2).

## Tecnologías Principales
- Lenguaje: Vala
- Framework UI: GTK+ 3.0
- Dependencias: glib-2.0, gio-2.0, libsdl2-dev
- Sistema: Debian 13 (Trixie)

## Estándares de Codificación (Linting Rules)

### Estilo de Código y Formateo
- **Indentación:**
    - Indentación: 4 espacios.
    - Prohibido el uso de Tabs. Usar exclusivamente espacios.
- **Espaciado:** 
    - Un solo espacio antes de las llaves de apertura (`{`).
    - Un solo espacio antes de los paréntesis de apertura en estructuras de control.
    - Prohibido el uso de espacios dobles en cualquier parte del código.
    - Prohibido el espacio excesivo al final de las líneas (trailing whitespace).
- **Final de Archivo:** Asegurar que los archivos terminen con una sola línea nueva (newline) y sin espacios en blanco finales.
- **Sintaxis:**
    - Prohibido el uso de punto y coma doble (`;;`).
    - Prohibido el uso de elipsis (`...`) literales innecesarias.
    - Evitar plantillas de strings (string templates) innecesarias.

### Límites y Comentarios
- **Idioma/Lenguaje:** se usa Inglés Americano para valores fijos de cadenas de texto.
- **Longitud de Línea:** Máximo 120 caracteres (ignorar esta regla en comentarios).
- **Notas de Seguimiento:** Marcar `TODO` y `FIXME` como advertencias (warnings).
- **Supresión:** Se permite deshabilitar reglas mediante comentarios inline (disable-by-inline-comments).

### Centralización de Constantes
- **Valores literales (strings):** Todas las cadenas de texto fijas (rutas, nombres de archivos, acciones, clases CSS, nombres de iconos, mensajes de UI, mensajes de error) deben definirse como constantes en `src/Constants.vala`. Prohibido usar valores literales directamente en el código fuente fuera de `Constants.vala`.
- **Organización:** Las constantes deben agruparse por categoría con comentarios de sección (ej: rutas Pi-Apps, etiquetas UI, mensajes de error, clases CSS).

### Convenciones de Nomenclatura (Naming Conventions)
- **Regla General:** Aplicar estrictamente las convenciones de Vala/GNOME (CamelCase para Clases, snake_case para métodos y variables).

## Comandos & Reglas

Para entender como compilar el proyecto o instalarlo en local puedes usar las instrucciones de:
- [compilar/build](.claude/comandos/compilar.md)
- [instalar/install](.claude/comandos/instalar.md)

## Estructura del proyecto

Encontraras la estructura que necesitamos para este proyecto en [proyect-structure.md](.claude/reglas/project-structure.md).

## Referencia & Documentacion

Si necesitas saber como usar una clase o metodo de una clase de Vala, GTK+, GLib, etc. Busca las fuentes citadas en [framework.md](.claude/reglas/framework.md).
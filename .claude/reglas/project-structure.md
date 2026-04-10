# Estructura del Proyecto

El proyecto debe contar con la siguiente estructura:

```sh
├── data/
│   ├── icons/
│   │   ├── 128/
│   │   │   └── dpad-store.svg
│   │   ├── 16/
│   │   │   └── dpad-store.svg
│   │   ├── 24/
│   │   │   └── dpad-store.svg
│   │   ├── 32/
│   │   │   └── dpad-store.svg
│   │   ├── 48/
│   │   │   └── dpad-store.svg
│   │   └── 64/
│   │       └── dpad-store.svg
│   ├── io.github.libredeb.dpad-store.1  # Contenido de man pages en formato groff macro syntax.
│   ├── io.github.libredeb.dpad-store.appdata.xml.in  # Metadata para las tiendas de software.
│   ├── io.github.libredeb.dpad-store.desktop.in  # Entrada .desktop para abrir el software.
│   └── io.github.libredeb.dpad-store.gresource.xml  # Cualquier recurso GTK
├── src/
│   ├── Backend/
│   │   └── *.vala
│   ├── Widgets/
│   │   └── *.vala
│   ├── Application.vala  # Gtk.Application (con metodo "build_and_run()" para la interfaz, activate, etc)
│   ├── Config.vala.in  # Para heredar el nombre y version de la app
│   ├── Constants.vala  # Para strings harcodeados, paths a archivos, etc.
│   └── Main.vala  # Instanciacion de la App y ejecucion
├── vapi/
│   └── config.vapi  # Como leer desde meson.build el nombre y version de la app
├── .gitignore
├── AUTHORS
├── COPYING
├── INSTALL
├── meson.build
├── post_install.py  # Para actualizar la cache de iconos de gtk
└── README.md
```

Antes de implementar alguno de estos archivos pideme ejemplos para complementar.
# 🍷 Admin Licores — App de Administración para Empresa de Licores/Abarrotes/Confitería

App nativa de iOS (iPhone 11) desarrollada con **SwiftUI + MVVM** y estética **Liquid Glass** femenina y chic. Ayuda al administrador a no olvidar sus funciones diarias con recordatorios programados.

## ✨ Funcionalidades

### 🔔 Recordatorios programados (con notificaciones)
- **Avances a Proveedores** — lunes, martes y miércoles (3 proveedores).
- **Avances por Vendedor** — martes, jueves y sábado.
- **Revisión de Liquidación de Viáticos** — todos los lunes.
- **Recordatorios personalizados** — crea los tuyos eligiendo días y hora.
- Cada recordatorio programa notificaciones locales reales para que *no los olvides*.

### 👑 Pedidos y Requerimientos del CEO (Renzo Campos)
- Ingresa pedidos/requerimientos con prioridad (alta/media/baja) y fecha límite.
- Marca como atendidos y archívalos.
- **Deshacer**: al eliminar un pedido (papelera), aparece una barra inferior "Deshacer" de 3 segundos para restaurarlo al instante.

### ☕ Consumos de Oficina (descuento a fin de mes)
- Registra productos que el personal consume del almacén (café, snacks, etc.).
- **Atajos de productos**: elige desde el catálogo del almacén (con precio) sin escribir nada.
- Agrega miembros de oficina y asigna consumos a cada uno.
- Resumen del mes por miembro y **total a facturar/descontar a fin de mes**.

### ⚙️ Configuración
- Edita la lista de **proveedores** (agregar/quitar/modificar nombres).
- Gestiona tus **vendedores** con **nombre, zona y teléfono** (agregar/editar/eliminar).
- Gestiona catálogo de productos y recordatorios.
- Control de permisos de notificaciones.

## 📱 Requisitos
- **Xcode 15+** (recomendado Xcode 16/26 para el efecto Liquid Glass completo).
- **iOS 16.0+** como deployment target (compatible con iPhone 11).
- El efecto *Liquid Glass* se aplica automáticamente en **iOS 26+**; en iOS 16–18 usa un material translúcido elegante equivalente.

## 🚀 Compilar e instalar SIN Mac (Windows + nube + Sideloadly)

**¿Necesitas un Mac? No.** Compilamos en un **Mac en la nube** (Codemagic, gratis) y
la app la instalamos en tu iPhone 11 con **Sideloadly** (programa para Windows, gratis).
No hace falta pagar la cuota anual de Apple Developer.

### Paso 1 · Subir el proyecto a GitHub (una sola vez, gratis)
1. Crea una cuenta en <https://github.com> (gratis).
2. Crea un **nuevo repositorio** (New repository) llamado `AdminLicoresApp` (público o privado).
3. Copia la carpeta `AdminLicoresApp` a tu GitHub (igual que subirías archivos normales),
   o usa Git: `git init`, `git add .`, `git commit`, y `git push` a tu repositorio.

### Paso 2 · Compilar en Codemagic (Mac en la nube, gratis)
1. Entra en <https://codemagic.io/start/> e inicia sesión **con tu cuenta de GitHub**.
2. Toca **Add application**, elige tu repositorio `AdminLicoresApp` y acéptalo.
3. Abre el workflow **"Build & Export IPA (para Sideloadly)"** (definido en `codemagic.yaml`).
4. Pulsa **Start build**. En ~5–10 min notificarás que terminó.
5. Descarga el artefacto **`AdminLicores-sideload.ipa`**.

### Paso 3 · Instalar la app en tu iPhone con Sideloadly (PC Windows, gratis)
1. Descarga e instala **Sideloadly** en tu PC Windows: <https://sideloadly.io/> (botón "Windows").
2. Conecta tu **iPhone 11** al PC por **cable USB** y desblócalo (confía en el PC si lo pide).
3. Abre Sideloadly, arrastra el archivo `AdminLicores-sideload.ipa` a la ventana.
4. Introduce tu **Apple ID** (el mismo de tu iPhone) y contraseña.
5. Toca **Start** y espera a que se instale.
6. En el iPhone: **Ajustes → General → VPN y gestión de dispositivos → Confiar** en tu Apple ID.
7. Abre la app **Admin Licores** 🎉

> ⏳ **Importante con Apple ID gratuito:** la app se instala y funciona, pero Apple la hace
> **expirar a los 7 días**. Para renovarla, basta con volver a conectarla en Sideloadly
> y pulsar *Start* (re-firma en unos segundos, tus datos NO se pierden).
> Con una cuenta de Apple Developer de pago (~$99/año) la app dura 1 año sin re-firmar.

### Soluciona el "no funciona / no se instala"
- Si Sideloadly no encuentra el iPhone: instala **iTunes** y **iCloud**
  (las [últimas versiones](https://support.apple.com/en-us/HT210384) de Windows) y reinicia.
- Si el iPhone pide confiar en el PC: toca "Confiar" cuando aparezca.
- Si la app no abre la primera vez: ve a **Ajustes → General → VPN y gestión de dispositivos**
  y toca **Confiar** bajo tu Apple ID.

## 🗂️ Estructura del proyecto
```
AdminLicoresApp/
├── AdminLicores.xcodeproj/        # Proyecto Xcode (NO se sube; se regenera con XcodeGen)
├── project.yml                    # Definición XcodeGen (source de verdad)
├── codemagic.yaml                 # Compilación en la nube (Mac virtual, para generar el .ipa)
├── .gitignore                     # Ignora archivos generados
├── README.md
└── AdminLicores/
    ├── AdminLicoresApp.swift      # Entrada de la app
    ├── Models/                    # Recordatorio, Consumo, Miembro, Pedido, Vendedor
    ├── ViewModels/                # AppViewModel (lógica de negocio)
    ├── Views/                     # Pantallas SwiftUI (tabs y detalle)
    ├── Services/                  # AppStore (persistencia), NotificationScheduler
    └── Support/                   # Tema (colores), Liquid Glass, helpers de fecha
```

## 🎨 Diseño
- Paleta **femenina y chic**: rosas, lavanda, malva y crema con degradados suaves.
- Tarjetas **glass** con bordes luminosos y sombras suaves.
- Tipografía *rounded*, iconografía SF Symbols y animaciones fluidas.
- Accesibilidad: Dynamic Type y targets táctiles ≥ 44pt.

---
*Hecho con 💗 para tu administración diaria.*

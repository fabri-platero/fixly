# Fixly

**Reportá problemas de tu ciudad.**

Fixly es una aplicación móvil hecha en Flutter para que los vecinos reporten problemas urbanos (baches, luminarias apagadas, basura acumulada, semáforos rotos, etc.) y para que los operadores municipales los gestionen hasta resolverlos.

Práctico N.º 3 – Práctico Integrador · Programación para Móviles · Tecnicatura Universitaria en Programación Web.

---

## Funcionalidades

### Ciudadano
- Registro e inicio de sesión con email y contraseña. La sesión queda guardada.
- Crear un reporte con:
  - categoría (9 opciones), título y descripción;
  - dirección o referencia escrita;
  - ubicación en un mapa, con el GPS ("Usar mi ubicación actual") o tocando el mapa ("Elegir en el mapa");
  - foto tomada con la cámara o elegida de la galería.
- Ver la lista de **sus propios** reportes con su estado.
- Ver el detalle de un reporte: foto, mapa, datos y estado.
- Editar o eliminar un reporte mientras siga **pendiente**.

### Operador
- Panel con **todos** los reportes de todos los vecinos.
- Cambiar el estado de cada reporte: `pendiente` → `en proceso` → `resuelto`.
- Ver el detalle completo, incluido quién lo reportó y dónde está en el mapa.

### Ciclo de vida de un reporte

```
pendiente  ──►  en proceso  ──►  resuelto
(lo crea el      (lo cambia el     (lo cambia el
 ciudadano)       operador)         operador)
```

Mientras un reporte está `pendiente`, su autor puede editarlo o borrarlo. Cuando el operador lo toma, queda bloqueado.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter / Dart | Aplicación móvil (Android) |
| Firebase Authentication | Registro, login y sesión (email y contraseña) |
| Cloud Firestore | Base de datos NoSQL en la nube |
| Reglas de seguridad de Firestore | Control de acceso y validación del lado del servidor |
| `image_picker` | Cámara y galería |
| `permission_handler` | Pedido y manejo formal de permisos |
| `geolocator` | Ubicación por GPS |
| `flutter_map` + `latlong2` + OpenStreetMap | Mapa con marcador, sin clave ni costo |

---

## Estructura del proyecto

```
lib/
├── main.dart                     Inicializa Firebase y carga el rol antes de abrir la app
├── firebase_options.dart         Configuración del proyecto de Firebase (generada por FlutterFire)
└── src/
    ├── app.dart                  MaterialApp y pantalla inicial según sesión y rol
    ├── models/
    │   └── reporte_model.dart    Modelo Reporte con fromMap / toMap
    ├── provider/
    │   ├── auth_provider.dart    Login, registro, cierre de sesión y rol del usuario
    │   └── reportes_provider.dart  CRUD de reportes en Firestore y cambio de estado
    ├── pages/
    │   ├── login_page.dart
    │   ├── registro_page.dart
    │   ├── home_page.dart        Lista de reportes del ciudadano
    │   ├── nuevo_reporte_page.dart  Alta y edición (cámara, galería, GPS y mapa)
    │   ├── detalle_reporte_page.dart
    │   └── panel_page.dart       Panel del operador
    ├── routes/
    │   └── routes.dart           Rutas con nombre
    └── utils/
        ├── reporte_util.dart     Íconos, colores, estados y formato de fecha
        └── mapa_util.dart        Mapa reutilizable (OpenStreetMap)
```

Las pantallas no hablan directo con Firebase: lo hacen a través de los **providers**. Si cambiara el backend, solo habría que modificar los providers.

---

## Arquitectura de la base de datos

Cloud Firestore, con dos colecciones.

### `reportes/{id}`

| Campo | Tipo | Descripción |
|---|---|---|
| `categoria` | string | `bache`, `luminaria`, `basura`, `semáforo`, `árbol caído`, `pérdida de agua`, `vereda rota`, `señalización`, `otro` |
| `titulo` | string | Obligatorio, de 1 a 100 caracteres |
| `descripcion` | string | Opcional |
| `direccion` | string | Dirección o referencia. Opcional si hay ubicación en el mapa |
| `estado` | string | `pendiente`, `en proceso` o `resuelto` |
| `uid` | string | UID del autor (Firebase Auth) |
| `email` | string | Email del autor, para que lo vea el operador |
| `foto` | string | Imagen JPG comprimida en base64 (vacía si no hay foto) |
| `latitud` | number / null | Coordenada del problema |
| `longitud` | number / null | Coordenada del problema |
| `fecha` | timestamp | Hora del servidor al crear el reporte |

### `usuarios/{uid}`

| Campo | Tipo | Descripción |
|---|---|---|
| `rol` | string | `operador` |

Solo existe para los operadores y se crea **a mano desde la consola de Firebase**. Ningún cliente puede escribir en esta colección. Si un usuario no tiene documento, es ciudadano.

### Decisiones de diseño
- **Email guardado dentro del reporte (desnormalización).** Firestore no tiene JOIN: guardar el email junto al reporte permite mostrar el autor con una sola consulta, en lugar de una lectura extra por cada reporte.
- **Foto en base64 dentro del documento.** Cloud Storage requiere el plan pago (Blaze). Para mantener el proyecto gratis, la foto se comprime (máx. 800 px, calidad 50 %) y se guarda como texto en el reporte. Las reglas limitan su tamaño.
- **Fecha del servidor** (`FieldValue.serverTimestamp()`), para que no dependa del reloj del teléfono.

---

## Seguridad

La configuración de `firebase_options.dart` y `google-services.json` está en el repositorio a propósito: son **identificadores públicos** del proyecto, no contraseñas, y viajan dentro de cualquier APK. La protección real está en **Firebase Authentication** y en las **reglas de seguridad de Firestore**, que se aplican en el servidor aunque alguien use otro programa en lugar de la app.

Las contraseñas nunca pasan por la base de datos: las maneja Firebase Authentication, que guarda solo un hash.

Resumen de las reglas:

| Acción | Ciudadano | Operador |
|---|---|---|
| Leer reportes | Solo los propios | Todos |
| Crear reporte | Sí, a su nombre, en `pendiente` y con datos válidos | — |
| Editar reporte | Solo los propios, en `pendiente`, sin tocar estado/autor/categoría | Solo el campo `estado` |
| Borrar reporte | Solo los propios, en `pendiente` | No |
| Escribir en `usuarios` | No | No (solo la consola) |

<details>
<summary>Reglas completas de Firestore</summary>

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function esOperador() {
      return request.auth != null
        && exists(/databases/$(database)/documents/usuarios/$(request.auth.uid))
        && get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'operador';
    }

    function coordenadaValida(valor, limite) {
      return valor == null || (valor is number && valor >= -limite && valor <= limite);
    }

    match /usuarios/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if false;
    }

    match /reportes/{id} {
      allow read: if request.auth != null
              && (resource.data.uid == request.auth.uid || esOperador());
      allow create: if request.auth != null
              && request.resource.data.keys().hasOnly(['categoria','titulo','descripcion','direccion','estado','uid','email','foto','latitud','longitud','fecha'])
              && request.resource.data.uid == request.auth.uid
              && request.resource.data.email == request.auth.token.email
              && request.resource.data.estado == 'pendiente'
              && request.resource.data.categoria in ['bache','luminaria','basura','semáforo','árbol caído','pérdida de agua','vereda rota','señalización','otro']
              && request.resource.data.titulo is string
              && request.resource.data.titulo.size() > 0
              && request.resource.data.titulo.size() <= 100
              && request.resource.data.foto is string
              && request.resource.data.foto.size() <= 700000
              && coordenadaValida(request.resource.data.latitud, 90)
              && coordenadaValida(request.resource.data.longitud, 180)
              && request.resource.data.fecha == request.time;
      allow update: if (request.auth != null
              && resource.data.uid == request.auth.uid
              && resource.data.estado == 'pendiente'
              && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['titulo','descripcion','direccion','foto','latitud','longitud'])
              && request.resource.data.titulo.size() > 0
              && request.resource.data.titulo.size() <= 100
              && request.resource.data.foto is string
              && request.resource.data.foto.size() <= 700000
              && coordenadaValida(request.resource.data.latitud, 90)
              && coordenadaValida(request.resource.data.longitud, 180))
            || (esOperador()
              && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['estado'])
              && request.resource.data.estado in ['pendiente','en proceso','resuelto']);
      allow delete: if request.auth != null
              && resource.data.uid == request.auth.uid
              && resource.data.estado == 'pendiente';
    }
  }
}
```

</details>

---

## Permisos del dispositivo

| Permiso | Para qué | Cuándo se pide |
|---|---|---|
| `CAMERA` | Sacar una foto del problema | Al tocar "Cámara" |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | Marcar la ubicación exacta con el GPS | Al tocar "Usar mi ubicación actual" |
| `INTERNET` | Comunicarse con Firebase y descargar el mapa | Se concede al instalar |

- Los permisos se piden **solo en el momento en que se necesitan**, nunca al abrir la app.
- Se manejan los tres casos: **concedido**, **denegado** (se explica para qué se necesita) y **bloqueado** (se ofrece abrir los ajustes de la app).
- Antes de usar el GPS se comprueba que la ubicación del teléfono esté activada.
- La **galería no requiere permiso**: Android muestra su selector de fotos del sistema y la app recibe solo la imagen elegida.
- La ubicación es **opcional**: sin dar el permiso, el usuario puede marcar el punto a mano con "Elegir en el mapa" o escribir la dirección.

---

## Cómo ejecutar

Requisitos: Flutter (canal stable) y un dispositivo Android o emulador.

```bash
flutter pub get
flutter run
```

La configuración de Firebase ya está incluida. Para usar un proyecto de Firebase propio:
1. Crear el proyecto y activar **Authentication → Email/Password** y **Cloud Firestore**.
2. Ejecutar `flutterfire configure` para regenerar `firebase_options.dart` y `google-services.json`.
3. Publicar las reglas de la sección **Seguridad** en Firestore → Reglas.

### Crear un operador
1. **Authentication → Agregar usuario**: crear la cuenta (por ejemplo `operador@fixly.com`) y copiar su **UID**.
2. **Firestore → colección `usuarios`**: crear un documento cuyo ID sea ese UID, con el campo `rol` (string) = `operador`.

Al iniciar sesión con esa cuenta, la app abre el panel del operador.

---

## Mejoras planificadas

- **Detección de reportes duplicados** por cercanía geográfica y categoría.
- **Fotos en Cloud Storage** en lugar de base64, para documentos más livianos y fotos de mayor calidad.
- **Recuperación de contraseña** y **verificación de email**.
- **Notificaciones push** al ciudadano cuando cambia el estado de su reporte.
- **Filtros y búsqueda** en el panel del operador (por estado, categoría o zona).
- **Mapa general** con todos los reportes como marcadores.
- **Dirección automática** a partir de las coordenadas (geocodificación inversa).
- **Administrador dentro de la app** para dar de alta operadores sin usar la consola.
- **Perfiles de usuario** (nombre, teléfono) en la colección `usuarios`.

---

## Autor

Fabrizio Platero

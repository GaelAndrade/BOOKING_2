# Sistema de Reservacion de Hoteles

## Portada

**Materia:** Desarrollo de Aplicaciones Moviles  
**Proyecto:** Sistema de Reservacion de Hoteles  
**Parcial:** Tercer parcial  
**Profesor:** [Nombre del profesor]  
**Integrantes:**  
- [Nombre completo integrante 1]
- [Nombre completo integrante 2]
- [Nombre completo integrante 3]

**Fecha:** [Fecha de entrega]

---

## 1. Introduccion

El presente proyecto consiste en una aplicacion movil desarrollada en Flutter
para la reservacion de habitaciones de hotel. La aplicacion permite iniciar
sesion, consultar hoteles disponibles, visualizar sus habitaciones, realizar
reservaciones, consultar reservas existentes, editarlas y eliminarlas.

Como parte de los requisitos del proyecto, se implemento una API RESTful
desarrollada en C# con ASP.NET Core. Esta API permite que la aplicacion movil
consuma endpoints mediante metodos HTTP como GET, POST, PUT y DELETE.

Ademas, la aplicacion conserva una base de datos local SQLite en el dispositivo
movil, con el objetivo de mantener informacion local y demostrar el uso de
almacenamiento persistente en el celular. De esta forma, el sistema trabaja con
una arquitectura que combina frontend movil, backend/API y almacenamiento local.

---

## 2. Objetivo

Desarrollar una aplicacion movil funcional para la gestion de reservaciones de
hotel, integrando una API RESTful en C# y una base de datos local SQLite en el
dispositivo movil.

Los objetivos especificos son:

- Consultar hoteles desde la aplicacion movil.
- Mostrar habitaciones disponibles por hotel.
- Registrar e iniciar sesion con usuarios.
- Crear, consultar, actualizar y eliminar reservaciones.
- Consumir endpoints de una API RESTful mediante GET, POST, PUT y DELETE.
- Guardar informacion localmente en SQLite.
- Sincronizar datos de reservaciones con el backend.

---

## 3. Arquitectura Del Sistema

El sistema esta compuesto por tres partes principales:

```txt
Aplicacion movil Flutter
        |
        | HTTP / REST
        v
API RESTful C# ASP.NET Core
        |
        v
Persistencia del backend

Aplicacion movil Flutter
        |
        v
SQLite local del dispositivo
```

La aplicacion movil funciona como el frontend del sistema. Desde ella, el
usuario puede navegar por las pantallas, iniciar sesion, consultar hoteles y
gestionar reservaciones.

La API RESTful funciona como backend. Esta recibe solicitudes HTTP desde la app
movil, procesa la informacion y guarda los datos del servidor.

La base de datos SQLite local se encuentra dentro del dispositivo movil y sirve
para conservar una copia local de la informacion relevante, como usuarios,
hoteles, habitaciones y reservaciones.

---

## 4. Tecnologias Utilizadas

- **Flutter:** desarrollo de la aplicacion movil.
- **Dart:** lenguaje utilizado en Flutter.
- **C# ASP.NET Core:** desarrollo de la API RESTful.
- **SQLite / sqflite:** base de datos local en el dispositivo movil.
- **Firebase Auth:** autenticacion con Google.
- **Google Sign-In:** inicio de sesion con cuenta Google.
- **Android Studio:** ejecucion, inspeccion y pruebas de la aplicacion.
- **Database Inspector:** visualizacion de tablas SQLite en el dispositivo.
- **JSON:** persistencia academica del backend.

---

## 5. Base De Datos Local SQLite

La aplicacion movil utiliza SQLite para almacenar informacion localmente en el
dispositivo. La base de datos se llama:

```txt
booking_local.db
```

Las tablas principales son:

```txt
usuarios
hoteles
habitaciones
reservaciones
```

### Tabla usuarios

Esta tabla almacena la informacion de los usuarios registrados o sincronizados.

Campos principales:

```txt
id
google_uid
nombre
email
password
foto_url
created_at
```

### Tabla hoteles

Esta tabla almacena los hoteles disponibles en la aplicacion.

Campos principales:

```txt
id
nombre
ciudad
direccion
descripcion
precio_noche
imagen_url
calificacion
created_at
```

### Tabla habitaciones

Esta tabla almacena las habitaciones correspondientes a cada hotel.

Campos principales:

```txt
id
hotel_id
nombre
descripcion
precio
imagen_url
created_at
```

### Tabla reservaciones

Esta tabla almacena las reservaciones realizadas por los usuarios.

Campos principales:

```txt
id
usuario_id
hotel_id
habitacion_nombre
fecha_entrada
fecha_salida
huespedes
total
estado
created_at
```

**Captura sugerida:** insertar captura de Android Studio Database Inspector
mostrando las tablas de SQLite.

---

## 6. Backend API RESTful

El backend del proyecto fue desarrollado en C# utilizando ASP.NET Core. Se
encuentra en la carpeta:

```txt
BookingApi
```

Para ejecutar el servidor se utiliza el siguiente comando:

```powershell
dotnet run --no-launch-profile --project BookingApi\BookingApi.csproj --urls http://0.0.0.0:5090
```

Cuando el servidor esta activo, la aplicacion movil puede consumir la API desde
la red local. Por ejemplo:

```txt
http://192.168.1.87:5090
```

### Endpoints Implementados

| Metodo | Endpoint | Descripcion |
|---|---|---|
| GET | /api/hoteles | Obtiene todos los hoteles |
| GET | /api/hoteles/{id} | Obtiene un hotel por ID |
| GET | /api/hoteles/{id}/habitaciones | Obtiene habitaciones de un hotel |
| GET | /api/usuarios | Obtiene usuarios registrados |
| POST | /api/usuarios | Registra un usuario |
| POST | /api/usuarios/login | Inicia sesion con correo y password |
| PUT | /api/usuarios/{id} | Actualiza datos de usuario |
| GET | /api/reservaciones | Obtiene todas las reservaciones |
| GET | /api/reservaciones/usuario/{usuarioId} | Obtiene reservaciones por usuario |
| POST | /api/reservaciones | Crea una reservacion |
| PUT | /api/reservaciones/{id} | Actualiza una reservacion |
| DELETE | /api/reservaciones/{id} | Elimina una reservacion |

---

## 7. CRUD De Reservaciones

El CRUD principal del sistema se realiza sobre las reservaciones.

### Create

Se utiliza el metodo POST para crear una nueva reservacion.

```txt
POST /api/reservaciones
```

### Read

Se utiliza GET para consultar reservaciones.

```txt
GET /api/reservaciones
GET /api/reservaciones/usuario/{usuarioId}
```

### Update

Se utiliza PUT para modificar una reservacion existente.

```txt
PUT /api/reservaciones/{id}
```

### Delete

Se utiliza DELETE para eliminar una reservacion.

```txt
DELETE /api/reservaciones/{id}
```

---

## 8. Consumo De La API Desde Flutter

La aplicacion movil consume la API mediante una clase cliente ubicada en:

```txt
lib/data/api_client.dart
```

Esta clase contiene los metodos generales para comunicarse con el backend:

```dart
get()
post()
put()
delete()
```

Los repositorios de Flutter utilizan este cliente para consumir los endpoints.
Los archivos principales son:

```txt
lib/repositories/hotel_repository.dart
lib/repositories/habitacion_repository.dart
lib/repositories/usuario_repository.dart
lib/repositories/reservacion_repository.dart
```

El repositorio de reservaciones es el encargado de crear, consultar, actualizar
y eliminar reservas usando la API RESTful. Tambien actualiza la copia local en
SQLite.

---

## 9. Flujo De Funcionamiento

El flujo general de la aplicacion es el siguiente:

```txt
Usuario abre la app
        |
        v
Inicia sesion con Google o correo/password
        |
        v
La app sincroniza el usuario con la API
        |
        v
Consulta hoteles disponibles
        |
        v
Selecciona un hotel
        |
        v
Consulta habitaciones del hotel
        |
        v
Selecciona habitacion y fechas
        |
        v
Crea una reservacion
        |
        v
La reservacion se guarda en el servidor
        |
        v
La reservacion tambien se guarda en SQLite local
        |
        v
El usuario puede consultar, editar o eliminar sus reservaciones
```

Si el usuario inicia sesion con la misma cuenta en otro dispositivo conectado a
la misma API, puede consultar las reservaciones guardadas en el servidor.

---

## 10. Pantallas Del Sistema

### Pantalla de inicio de sesion

Permite iniciar sesion mediante correo y password o mediante una cuenta de
Google.

**Captura:** insertar pantalla de login.

### Pantalla de registro

Permite crear un usuario local con nombre, correo y password.

**Captura:** insertar pantalla de registro.

### Pantalla principal

Muestra los hoteles disponibles para reservar.

**Captura:** insertar pantalla principal.

### Detalle de hotel

Muestra informacion detallada del hotel seleccionado, como descripcion,
servicios y opcion para ver habitaciones.

**Captura:** insertar detalle de hotel.

### Habitaciones

Muestra las habitaciones disponibles para el hotel seleccionado, incluyendo
precio, descripcion e imagen.

**Captura:** insertar pantalla de habitaciones.

### Reservacion

Permite seleccionar fechas, numero de huespedes y confirmar una reservacion.

**Captura:** insertar pantalla de reservacion.

### Mis reservaciones

Muestra las reservaciones realizadas por el usuario. Desde esta pantalla se
pueden editar o eliminar reservas.

**Captura:** insertar pantalla de mis reservaciones.

### Perfil

Muestra y permite actualizar informacion del usuario.

**Captura:** insertar pantalla de perfil.

---

## 11. Pruebas De Funcionamiento

### Prueba 1: Consulta de hoteles

Se ejecuto la API y se consulto el endpoint:

```txt
GET /api/hoteles
```

Resultado: la API regreso la lista de hoteles disponibles.

**Captura:** insertar navegador mostrando `/api/hoteles`.

### Prueba 2: Creacion de reservacion

Desde la aplicacion movil se selecciono un hotel, una habitacion y fechas de
entrada/salida. Al confirmar, la app envio una solicitud:

```txt
POST /api/reservaciones
```

Resultado: la reservacion se guardo correctamente.

**Captura:** insertar pantalla de confirmacion o Mis reservaciones.

### Prueba 3: Verificacion en API

Despues de crear la reservacion, se consulto:

```txt
GET /api/reservaciones
```

Resultado: la reservacion aparece registrada en el servidor.

**Captura:** insertar navegador mostrando `/api/reservaciones`.

### Prueba 4: Verificacion en SQLite

Se abrio Android Studio Database Inspector y se reviso la tabla:

```txt
reservaciones
```

Resultado: la misma reservacion aparece almacenada localmente en el celular.

**Captura:** insertar Database Inspector mostrando tabla reservaciones.

### Prueba 5: Edicion y eliminacion

Se edito una reservacion existente y posteriormente se elimino.

Metodos utilizados:

```txt
PUT /api/reservaciones/{id}
DELETE /api/reservaciones/{id}
```

Resultado: los cambios se reflejaron en la API y en SQLite local.

**Captura:** insertar evidencia de edicion/eliminacion.

---

## 12. Conclusion

Se desarrollo una aplicacion movil funcional para la reservacion de habitaciones
de hotel. El proyecto integra una API RESTful desarrollada en C# ASP.NET Core y
una base de datos local SQLite en el dispositivo movil.

La aplicacion consume endpoints mediante los metodos HTTP GET, POST, PUT y
DELETE, cumpliendo con las operaciones CRUD requeridas. Ademas, el sistema
mantiene una copia local de los datos en SQLite, lo que permite demostrar el uso
de almacenamiento local dentro de la aplicacion.

Con esta implementacion se cumple el objetivo de conectar una aplicacion movil
con un backend mediante API RESTful, mostrando tambien el funcionamiento de las
pantallas, la base de datos local y la gestion completa de reservaciones.

---

## 13. Anexos

### Comando para ejecutar la API

```powershell
dotnet run --no-launch-profile --project BookingApi\BookingApi.csproj --urls http://0.0.0.0:5090
```

### Comando para ejecutar Flutter en celular real

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.87:5090
```

### Archivos importantes

```txt
BookingApi/Program.cs
lib/data/api_client.dart
lib/data/app_database.dart
lib/repositories/reservacion_repository.dart
lib/controllers/reservacion_controller.dart
```

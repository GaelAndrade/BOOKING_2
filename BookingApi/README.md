# BookingApi

API REST academica para el proyecto movil de booking. Expone datos de hoteles,
habitaciones, usuarios y reservaciones para que la aplicacion Flutter consuma
endpoints HTTP en lugar de depender solo de SQLite local.

## Ejecutar

Desde la carpeta raiz del proyecto:

```powershell
dotnet run --no-launch-profile --project BookingApi\BookingApi.csproj --urls http://localhost:5090
```

URL base:

```txt
http://localhost:5090
```

Si se prueba desde un emulador Android, normalmente se usa:

```txt
http://10.0.2.2:5090
```

## Endpoints

```txt
GET    /api/hoteles
GET    /api/hoteles/{id}
GET    /api/hoteles/{id}/habitaciones

GET    /api/usuarios
POST   /api/usuarios
POST   /api/usuarios/login
PUT    /api/usuarios/{id}

GET    /api/reservaciones
GET    /api/reservaciones/usuario/{usuarioId}
POST   /api/reservaciones
PUT    /api/reservaciones/{id}
DELETE /api/reservaciones/{id}
```

## Usuario de prueba

```txt
Correo: local@booking.app
Password: 123456
```

## Persistencia

La API guarda los datos modificados en:

```txt
BookingApi/App_Data/booking-data.json
```

Ese archivo se genera automaticamente al ejecutar la API.

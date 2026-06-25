using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
});

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddSingleton<BookingStore>();

var app = builder.Build();

app.UseCors();

app.MapGet("/", () => Results.Ok(new
{
    mensaje = "Booking API funcionando",
    endpoints = new[]
    {
        "GET /api/hoteles",
        "GET /api/hoteles/{id}",
        "GET /api/hoteles/{id}/habitaciones",
        "GET /api/usuarios",
        "POST /api/usuarios",
        "POST /api/usuarios/login",
        "PUT /api/usuarios/{id}",
        "GET /api/reservaciones",
        "GET /api/reservaciones/usuario/{usuarioId}",
        "POST /api/reservaciones",
        "PUT /api/reservaciones/{id}",
        "DELETE /api/reservaciones/{id}"
    }
}));

app.MapGet("/api/hoteles", (BookingStore store) =>
{
    return Results.Ok(store.GetHoteles());
});

app.MapGet("/api/hoteles/{id:int}", (int id, BookingStore store) =>
{
    var hotel = store.GetHotel(id);
    return hotel is null ? Results.NotFound() : Results.Ok(hotel);
});

app.MapGet("/api/hoteles/{id:int}/habitaciones", (int id, BookingStore store) =>
{
    if (store.GetHotel(id) is null) return Results.NotFound("Hotel no encontrado.");
    return Results.Ok(store.GetHabitacionesPorHotel(id));
});

app.MapGet("/api/usuarios", (BookingStore store) =>
{
    return Results.Ok(store.GetUsuarios());
});

app.MapPost("/api/usuarios", (Usuario usuario, BookingStore store) =>
{
    var resultado = store.CrearUsuario(usuario);
    return resultado.Exito
        ? Results.Created($"/api/usuarios/{resultado.Usuario!.Id}", resultado.Usuario)
        : Results.BadRequest(resultado.Mensaje);
});

app.MapPost("/api/usuarios/login", (LoginRequest login, BookingStore store) =>
{
    var usuario = store.Login(login.Email, login.Password);
    return usuario is null
        ? Results.Unauthorized()
        : Results.Ok(usuario);
});

app.MapPut("/api/usuarios/{id:int}", (int id, Usuario usuario, BookingStore store) =>
{
    var actualizado = store.ActualizarUsuario(id, usuario);
    return actualizado is null ? Results.NotFound() : Results.Ok(actualizado);
});

app.MapGet("/api/reservaciones", (BookingStore store) =>
{
    return Results.Ok(store.GetReservaciones());
});

app.MapGet("/api/reservaciones/usuario/{usuarioId:int}", (int usuarioId, BookingStore store) =>
{
    return Results.Ok(store.GetReservacionesPorUsuario(usuarioId));
});

app.MapPost("/api/reservaciones", (Reservacion reservacion, BookingStore store) =>
{
    var resultado = store.CrearReservacion(reservacion);
    return resultado.Exito
        ? Results.Created($"/api/reservaciones/{resultado.Reservacion!.Id}", resultado.Reservacion)
        : Results.BadRequest(resultado.Mensaje);
});

app.MapPut("/api/reservaciones/{id:int}", (int id, Reservacion reservacion, BookingStore store) =>
{
    var resultado = store.ActualizarReservacion(id, reservacion);
    if (resultado.NoEncontrado) return Results.NotFound();
    return resultado.Exito ? Results.Ok(resultado.Reservacion) : Results.BadRequest(resultado.Mensaje);
});

app.MapDelete("/api/reservaciones/{id:int}", (int id, BookingStore store) =>
{
    return store.EliminarReservacion(id) ? Results.NoContent() : Results.NotFound();
});

app.Run();

public sealed class BookingStore
{
    private readonly object _lock = new();
    private readonly string _filePath;
    private BookingData _data;

    public BookingStore(IHostEnvironment environment)
    {
        var dataDirectory = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDirectory);
        _filePath = Path.Combine(dataDirectory, "booking-data.json");
        _data = LoadData();
    }

    public List<Hotel> GetHoteles()
    {
        lock (_lock) return _data.Hoteles.OrderBy(hotel => hotel.Id).ToList();
    }

    public Hotel? GetHotel(int id)
    {
        lock (_lock) return _data.Hoteles.FirstOrDefault(hotel => hotel.Id == id);
    }

    public List<Habitacion> GetHabitacionesPorHotel(int hotelId)
    {
        lock (_lock)
        {
            return _data.Habitaciones
                .Where(habitacion => habitacion.HotelId == hotelId)
                .OrderBy(habitacion => habitacion.Id)
                .ToList();
        }
    }

    public List<Usuario> GetUsuarios()
    {
        lock (_lock) return _data.Usuarios.OrderBy(usuario => usuario.Id).ToList();
    }

    public UsuarioResult CrearUsuario(Usuario usuario)
    {
        lock (_lock)
        {
            if (_data.Usuarios.Any(actual =>
                    actual.Email.Equals(usuario.Email, StringComparison.OrdinalIgnoreCase)))
            {
                return UsuarioResult.Error("Ya existe un usuario con ese correo.");
            }

            usuario.Id = NextId(_data.Usuarios.Select(actual => actual.Id));
            usuario.CreatedAt = usuario.CreatedAt == 0
                ? DateTimeOffset.Now.ToUnixTimeMilliseconds()
                : usuario.CreatedAt;
            _data.Usuarios.Add(usuario);
            SaveData();
            return UsuarioResult.Ok(usuario);
        }
    }

    public Usuario? Login(string email, string password)
    {
        lock (_lock)
        {
            return _data.Usuarios.FirstOrDefault(usuario =>
                usuario.Email.Equals(email, StringComparison.OrdinalIgnoreCase)
                && usuario.Password == password);
        }
    }

    public Usuario? ActualizarUsuario(int id, Usuario usuario)
    {
        lock (_lock)
        {
            var index = _data.Usuarios.FindIndex(actual => actual.Id == id);
            if (index < 0) return null;

            usuario.Id = id;
            usuario.CreatedAt = _data.Usuarios[index].CreatedAt;
            _data.Usuarios[index] = usuario;
            SaveData();
            return usuario;
        }
    }

    public List<Reservacion> GetReservaciones()
    {
        lock (_lock)
        {
            return _data.Reservaciones
                .OrderByDescending(reservacion => reservacion.CreatedAt)
                .ToList();
        }
    }

    public List<Reservacion> GetReservacionesPorUsuario(int usuarioId)
    {
        lock (_lock)
        {
            return _data.Reservaciones
                .Where(reservacion => reservacion.UsuarioId == usuarioId)
                .OrderByDescending(reservacion => reservacion.CreatedAt)
                .ToList();
        }
    }

    public ReservacionResult CrearReservacion(Reservacion reservacion)
    {
        lock (_lock)
        {
            var validacion = ValidarReservacion(reservacion);
            if (validacion is not null) return ReservacionResult.Error(validacion);

            if (ExisteEmpalme(reservacion)) {
                return ReservacionResult.Error("La habitacion no esta disponible en esas fechas.");
            }

            reservacion.Id = NextId(_data.Reservaciones.Select(actual => actual.Id));
            reservacion.CreatedAt = reservacion.CreatedAt == 0
                ? DateTimeOffset.Now.ToUnixTimeMilliseconds()
                : reservacion.CreatedAt;
            reservacion.Estado = string.IsNullOrWhiteSpace(reservacion.Estado)
                ? "confirmada"
                : reservacion.Estado;
            _data.Reservaciones.Add(reservacion);
            SaveData();
            return ReservacionResult.Ok(reservacion);
        }
    }

    public ReservacionResult ActualizarReservacion(int id, Reservacion reservacion)
    {
        lock (_lock)
        {
            var index = _data.Reservaciones.FindIndex(actual => actual.Id == id);
            if (index < 0) return ReservacionResult.NotFound();

            var validacion = ValidarReservacion(reservacion);
            if (validacion is not null) return ReservacionResult.Error(validacion);

            reservacion.Id = id;
            if (ExisteEmpalme(reservacion)) {
                return ReservacionResult.Error("La habitacion no esta disponible en esas fechas.");
            }

            reservacion.CreatedAt = _data.Reservaciones[index].CreatedAt;
            _data.Reservaciones[index] = reservacion;
            SaveData();
            return ReservacionResult.Ok(reservacion);
        }
    }

    public bool EliminarReservacion(int id)
    {
        lock (_lock)
        {
            var reservacion = _data.Reservaciones.FirstOrDefault(actual => actual.Id == id);
            if (reservacion is null) return false;
            _data.Reservaciones.Remove(reservacion);
            SaveData();
            return true;
        }
    }

    private string? ValidarReservacion(Reservacion reservacion)
    {
        if (_data.Usuarios.All(usuario => usuario.Id != reservacion.UsuarioId)) {
            return "Usuario no encontrado.";
        }

        if (_data.Hoteles.All(hotel => hotel.Id != reservacion.HotelId)) {
            return "Hotel no encontrado.";
        }

        if (reservacion.FechaSalida <= reservacion.FechaEntrada) {
            return "La fecha de salida debe ser posterior a la fecha de entrada.";
        }

        if (reservacion.Huespedes < 1) {
            return "Selecciona al menos un huesped.";
        }

        return null;
    }

    private bool ExisteEmpalme(Reservacion reservacion)
    {
        return _data.Reservaciones.Any(actual =>
            actual.Id != reservacion.Id
            && actual.HotelId == reservacion.HotelId
            && actual.HabitacionNombre.Equals(reservacion.HabitacionNombre, StringComparison.OrdinalIgnoreCase)
            && actual.FechaEntrada < reservacion.FechaSalida
            && actual.FechaSalida > reservacion.FechaEntrada);
    }

    private BookingData LoadData()
    {
        if (!File.Exists(_filePath)) return BookingData.CreateSeedData();

        var json = File.ReadAllText(_filePath);
        return JsonSerializer.Deserialize<BookingData>(json, JsonOptions()) ?? BookingData.CreateSeedData();
    }

    private void SaveData()
    {
        var json = JsonSerializer.Serialize(_data, JsonOptions());
        File.WriteAllText(_filePath, json);
    }

    private static JsonSerializerOptions JsonOptions()
    {
        return new JsonSerializerOptions
        {
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
        };
    }

    private static int NextId(IEnumerable<int> ids)
    {
        return ids.DefaultIfEmpty(0).Max() + 1;
    }
}

public sealed class BookingData
{
    public List<Usuario> Usuarios { get; set; } = [];
    public List<Hotel> Hoteles { get; set; } = [];
    public List<Habitacion> Habitaciones { get; set; } = [];
    public List<Reservacion> Reservaciones { get; set; } = [];

    public static BookingData CreateSeedData()
    {
        var now = DateTimeOffset.Now.ToUnixTimeMilliseconds();

        return new BookingData
        {
            Usuarios =
            [
                new Usuario
                {
                    Id = 1,
                    Nombre = "Usuario local",
                    Email = "local@booking.app",
                    Password = "123456",
                    CreatedAt = now
                }
            ],
            Hoteles =
            [
                new Hotel
                {
                    Id = 1,
                    Nombre = "Hotel Salinas",
                    Ciudad = "Poza Rica",
                    Direccion = "Boulevard Adolfo Ruiz Cortinez",
                    Descripcion = "Hotel Salinas ofrece una estancia comoda cerca del boulevard.",
                    PrecioNoche = 1200,
                    ImagenUrl = "lib/imagenes/hotel_salinas.jpg",
                    Calificacion = 4,
                    CreatedAt = now
                },
                new Hotel
                {
                    Id = 2,
                    Nombre = "La Quinta",
                    Ciudad = "Poza Rica",
                    Direccion = "Zona centro de Poza Rica",
                    Descripcion = "La Quinta ofrece hospedaje practico y accesible en una zona centrica.",
                    PrecioNoche = 850,
                    ImagenUrl = "lib/imagenes/la_quinta.png",
                    Calificacion = 4,
                    CreatedAt = now
                },
                new Hotel
                {
                    Id = 3,
                    Nombre = "Hotel Paris",
                    Ciudad = "Poza Rica",
                    Direccion = "Av. Principal, Poza Rica",
                    Descripcion = "Hotel Paris es una opcion sencilla para estancias cortas.",
                    PrecioNoche = 650,
                    ImagenUrl = "lib/imagenes/hotel_paris.jpg",
                    Calificacion = 3,
                    CreatedAt = now
                },
                new Hotel
                {
                    Id = 4,
                    Nombre = "Hotel Victoria",
                    Ciudad = "Poza Rica",
                    Direccion = "Col. Obrera, Poza Rica",
                    Descripcion = "Hotel Victoria combina comodidad y ambiente familiar.",
                    PrecioNoche = 980,
                    ImagenUrl = "lib/imagenes/hotel_victoria.jpeg",
                    Calificacion = 4,
                    CreatedAt = now
                },
                new Hotel
                {
                    Id = 5,
                    Nombre = "Poza Rica Inn",
                    Ciudad = "Poza Rica",
                    Direccion = "Blvd. Adolfo Ruiz Cortines",
                    Descripcion = "Poza Rica Inn esta orientado a huespedes que buscan comodidad, buena ubicacion y servicios completos.",
                    PrecioNoche = 1700,
                    ImagenUrl = "lib/imagenes/poza_rica_inn.jpg",
                    Calificacion = 5,
                    CreatedAt = now
                }
            ],
            Habitaciones =
            [
                new Habitacion { Id = 1, HotelId = 1, Nombre = "Habitacion doble", Descripcion = "Habitacion con dos camas matrimoniales, bano privado, ropa de cama de alta calidad y cafetera.", Precio = 1200, ImagenUrl = "lib/imagenes/salinas_doble.png", CreatedAt = now },
                new Habitacion { Id = 2, HotelId = 1, Nombre = "Suite familiar", Descripcion = "Espacio amplio para familias, con area de descanso, television y acceso a servicios del hotel.", Precio = 1750, ImagenUrl = "lib/imagenes/salinas_familiar.png", CreatedAt = now },
                new Habitacion { Id = 3, HotelId = 2, Nombre = "Habitacion estandar", Descripcion = "Habitacion comoda para estancias cortas, con bano privado, aire acondicionado y television.", Precio = 850, ImagenUrl = "lib/imagenes/la_quinta_estandar.jpg", CreatedAt = now },
                new Habitacion { Id = 4, HotelId = 2, Nombre = "Habitacion matrimonial", Descripcion = "Opcion practica para dos personas, con cama matrimonial, bano privado y servicio basico.", Precio = 1050, ImagenUrl = "lib/imagenes/la_quinta_matrimonial.jpg", CreatedAt = now },
                new Habitacion { Id = 5, HotelId = 3, Nombre = "Habitacion sencilla", Descripcion = "Habitacion economica para una persona, ideal para una noche o estancia breve.", Precio = 650, ImagenUrl = "lib/imagenes/paris_sencilla.jpg", CreatedAt = now },
                new Habitacion { Id = 6, HotelId = 3, Nombre = "Habitacion doble", Descripcion = "Habitacion sencilla con dos camas, bano privado y servicios basicos para hospedaje accesible.", Precio = 900, ImagenUrl = "lib/imagenes/paris_doble_economica.jpg", CreatedAt = now },
                new Habitacion { Id = 7, HotelId = 4, Nombre = "Habitacion confort", Descripcion = "Habitacion tranquila con cama matrimonial, bano privado y ambiente familiar.", Precio = 980, ImagenUrl = "lib/imagenes/victoria_confort.jpg", CreatedAt = now },
                new Habitacion { Id = 8, HotelId = 4, Nombre = "Habitacion familiar", Descripcion = "Espacio amplio para familias, con camas dobles, television y estacionamiento incluido.", Precio = 1450, ImagenUrl = "lib/imagenes/victoria_familiar.jpg", CreatedAt = now },
                new Habitacion { Id = 9, HotelId = 5, Nombre = "Habitacion ejecutiva", Descripcion = "Disenada para viajes de trabajo, cuenta con escritorio, cama king size y ambiente comodo.", Precio = 1900, ImagenUrl = "lib/imagenes/poza_ejec.jpg", CreatedAt = now },
                new Habitacion { Id = 10, HotelId = 5, Nombre = "Suite premium", Descripcion = "Suite amplia con cama king size, zona de estar, servicio a la habitacion y acceso a gimnasio.", Precio = 2600, ImagenUrl = "lib/imagenes/poza_suite.jpg", CreatedAt = now }
            ]
        };
    }
}

public sealed class Usuario
{
    public int Id { get; set; }
    public string? GoogleUid { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Password { get; set; }
    public string? FotoUrl { get; set; }
    public long CreatedAt { get; set; }
}

public sealed class Hotel
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Ciudad { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Descripcion { get; set; }
    public double PrecioNoche { get; set; }
    public string? ImagenUrl { get; set; }
    public double Calificacion { get; set; }
    public long CreatedAt { get; set; }
}

public sealed class Habitacion
{
    public int Id { get; set; }
    public int HotelId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public int Precio { get; set; }
    public string? ImagenUrl { get; set; }
    public long CreatedAt { get; set; }
}

public sealed class Reservacion
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public int HotelId { get; set; }
    public string HabitacionNombre { get; set; } = string.Empty;
    public long FechaEntrada { get; set; }
    public long FechaSalida { get; set; }
    public int Huespedes { get; set; }
    public double Total { get; set; }
    public string Estado { get; set; } = "confirmada";
    public long CreatedAt { get; set; }
}

public sealed record LoginRequest(string Email, string Password);

public sealed record UsuarioResult(bool Exito, string Mensaje, Usuario? Usuario)
{
    public static UsuarioResult Ok(Usuario usuario) => new(true, string.Empty, usuario);
    public static UsuarioResult Error(string mensaje) => new(false, mensaje, null);
}

public sealed record ReservacionResult(bool Exito, bool NoEncontrado, string Mensaje, Reservacion? Reservacion)
{
    public static ReservacionResult Ok(Reservacion reservacion) => new(true, false, string.Empty, reservacion);
    public static ReservacionResult Error(string mensaje) => new(false, false, mensaje, null);
    public static ReservacionResult NotFound() => new(false, true, string.Empty, null);
}

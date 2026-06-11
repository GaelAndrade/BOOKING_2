// Creamos la base de datos y los métodos CRUD

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';
import '../modelo/reservacion.dart';
import '../modelo/usuario.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'booking_local.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onOpen: _seedInitialData,
    );
  }

  Future<void> _seedInitialData(Database db) async {
    await _insertarUsuarioInicial(db);
    await _insertarHotelesIniciales(db);
    await _insertarHabitacionesIniciales(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE habitaciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hotel_id INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          precio INTEGER NOT NULL,
          imagen_url TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (hotel_id) REFERENCES hoteles(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_habitaciones_hotel ON habitaciones(hotel_id)',
      );
      await _insertarHabitacionesIniciales(db);
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        google_uid TEXT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        foto_url TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE hoteles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        ciudad TEXT NOT NULL,
        direccion TEXT,
        descripcion TEXT,
        precio_noche REAL NOT NULL,
        imagen_url TEXT,
        calificacion REAL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habitaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hotel_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        precio INTEGER NOT NULL,
        imagen_url TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (hotel_id) REFERENCES hoteles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reservaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        hotel_id INTEGER NOT NULL,
        habitacion_nombre TEXT NOT NULL,
        fecha_entrada INTEGER NOT NULL,
        fecha_salida INTEGER NOT NULL,
        huespedes INTEGER NOT NULL,
        total REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        created_at INTEGER NOT NULL,

        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY (hotel_id) REFERENCES hoteles(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_habitaciones_hotel ON habitaciones(hotel_id)',
    );
    await db.execute(
      'CREATE INDEX idx_reservaciones_usuario ON reservaciones(usuario_id)',
    );
    await db.execute(
      'CREATE INDEX idx_reservaciones_hotel ON reservaciones(hotel_id)',
    );

    await _insertarHotelesIniciales(db);
    await _insertarHabitacionesIniciales(db);
  }

  Future<void> _insertarHotelesIniciales(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final hotelesIniciales = [
      {
        'nombre': 'Hotel Salinas',
        'ciudad': 'Poza Rica',
        'direccion': 'Boulevard Adolfo Ruiz Cortinez',
        'descripcion':
            'Hotel Salinas ofrece una estancia cómoda cerca del boulevard.',
        'precio_noche': 1200.0,
        'imagen_url': '',
        'calificacion': 4.0,
      },
      {
        'nombre': 'La Quinta',
        'ciudad': 'Poza Rica',
        'direccion': 'Zona centro de Poza Rica',
        'descripcion':
            'La Quinta ofrece hospedaje práctico y accesible en una zona céntrica.',
        'precio_noche': 850.0,
        'imagen_url': '',
        'calificacion': 4.0,
      },
      {
        'nombre': 'Hotel Paris',
        'ciudad': 'Poza Rica',
        'direccion': 'Av. Principal, Poza Rica',
        'descripcion':
            'Hotel Paris es una opción sencilla para estancias cortas.',
        'precio_noche': 650.0,
        'imagen_url': '',
        'calificacion': 3.0,
      },
      {
        'nombre': 'Hotel Victoria',
        'ciudad': 'Poza Rica',
        'direccion': 'Col. Obrera, Poza Rica',
        'descripcion': 'Hotel Victoria combina comodidad y ambiente familiar.',
        'precio_noche': 980.0,
        'imagen_url': '',
        'calificacion': 4.0,
      },
      {
        'nombre': 'Hotel Paraíso',
        'ciudad': 'Cancún',
        'direccion': 'Zona hotelera',
        'descripcion': 'Hotel frente al mar con alberca y restaurante.',
        'precio_noche': 1800.0,
        'imagen_url': '',
        'calificacion': 4.5,
      },
      {
        'nombre': 'Hotel Centro',
        'ciudad': 'Ciudad de México',
        'direccion': 'Centro histórico',
        'descripcion': 'Hotel cómodo cerca de zonas turísticas.',
        'precio_noche': 950.0,
        'imagen_url': '',
        'calificacion': 4.2,
      },
    ];

    for (final hotelData in hotelesIniciales) {
      await db.insert('hoteles', {
        ...hotelData,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _insertarUsuarioInicial(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('usuarios', {
      'google_uid': null,
      'nombre': 'Usuario local',
      'email': 'local@booking.app',
      'foto_url': null,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _insertarHabitacionesIniciales(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final habitacionesIniciales = [
      {
        'hotel_nombre': 'Hotel Salinas',
        'nombre': 'Habitación doble',
        'descripcion':
            'Habitación con dos camas matrimoniales, baño privado, ropa de cama de alta calidad y cafetera.',
        'precio': 1200,
        'imagen_url': 'lib/imagenes/salinas_doble.png',
      },
      {
        'hotel_nombre': 'Hotel Salinas',
        'nombre': 'Suite familiar',
        'descripcion':
            'Espacio amplio para familias, con área de descanso, televisión y acceso a servicios del hotel.',
        'precio': 1750,
        'imagen_url': 'lib/imagenes/salinas_familiar.png',
      },
      {
        'hotel_nombre': 'La Quinta',
        'nombre': 'Habitación estándar',
        'descripcion':
            'Habitación cómoda para estancias cortas, con baño privado, aire acondicionado y televisión.',
        'precio': 850,
        'imagen_url': 'lib/imagenes/la_quinta_estandar.jpg',
      },
      {
        'hotel_nombre': 'La Quinta',
        'nombre': 'Habitación matrimonial',
        'descripcion':
            'Opción práctica para dos personas, con cama matrimonial, baño privado y servicio básico.',
        'precio': 1050,
        'imagen_url': 'lib/imagenes/la_quinta_matrimonial.jpg',
      },
      {
        'hotel_nombre': 'Hotel Paris',
        'nombre': 'Habitación sencilla',
        'descripcion':
            'Habitación económica para una persona, ideal para una noche o estancia breve.',
        'precio': 650,
        'imagen_url': 'lib/imagenes/paris_sencilla.jpg',
      },
      {
        'hotel_nombre': 'Hotel Paris',
        'nombre': 'Habitación doble',
        'descripcion':
            'Habitación sencilla con dos camas, baño privado y servicios básicos para hospedaje accesible.',
        'precio': 900,
        'imagen_url': 'lib/imagenes/paris_doble_economica.jpg',
      },
      {
        'hotel_nombre': 'Hotel Victoria',
        'nombre': 'Habitación confort',
        'descripcion':
            'Habitación tranquila con cama matrimonial, baño privado y ambiente familiar.',
        'precio': 980,
        'imagen_url': 'lib/imagenes/victoria_confort.jpg',
      },
      {
        'hotel_nombre': 'Hotel Victoria',
        'nombre': 'Habitación familiar',
        'descripcion':
            'Espacio amplio para familias, con camas dobles, televisión y estacionamiento incluido.',
        'precio': 1450,
        'imagen_url': 'lib/imagenes/victoria_familiar.jpg',
      },
    ];

    for (final habitacionData in habitacionesIniciales) {
      final hotelMaps = await db.query(
        'hoteles',
        where: 'nombre = ?',
        whereArgs: [habitacionData['hotel_nombre']],
        limit: 1,
      );
      if (hotelMaps.isEmpty) continue;
      final hotelId = hotelMaps.first['id'] as int;
      await db.insert('habitaciones', {
        'hotel_id': hotelId,
        'nombre': habitacionData['nombre'],
        'descripcion': habitacionData['descripcion'],
        'precio': habitacionData['precio'],
        'imagen_url': habitacionData['imagen_url'],
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<Hotel?> getHotelPorNombre(String nombre) async {
    final db = await database;
    final maps = await db.query(
      'hoteles',
      where: 'nombre = ?',
      whereArgs: [nombre],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Hotel.fromMap(maps.first);
  }

  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Usuario?> getUsuarioPorGoogleUid(String googleUid) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'google_uid = ?',
      whereArgs: [googleUid],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Usuario.fromMap(maps.first);
  }

  Future<Usuario?> getUsuarioPorEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Usuario.fromMap(maps.first);
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final db = await database;
    final maps = await db.query('usuarios');
    return maps.map((row) => Usuario.fromMap(row)).toList();
  }

  Future<int> insertHotel(Hotel hotel) async {
    final db = await database;
    return await db.insert(
      'hoteles',
      hotel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Hotel?> getHotelPorId(int id) async {
    final db = await database;
    final maps = await db.query(
      'hoteles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Hotel.fromMap(maps.first);
  }

  Future<List<Hotel>> getAllHotels() async {
    final db = await database;
    final maps = await db.query('hoteles');
    return maps.map((row) => Hotel.fromMap(row)).toList();
  }

  Future<int> insertHabitacion(Habitacion habitacion) async {
    final db = await database;
    return await db.insert('habitaciones', habitacion.toMap());
  }

  Future<List<Habitacion>> getHabitacionesPorHotel(int hotelId) async {
    final db = await database;
    final maps = await db.query(
      'habitaciones',
      where: 'hotel_id = ?',
      whereArgs: [hotelId],
    );
    return maps.map((row) => Habitacion.fromMap(row)).toList();
  }

  Future<int> insertReservacion(Reservacion reservacion) async {
    final db = await database;
    return await db.insert('reservaciones', reservacion.toMap());
  }

  Future<List<Reservacion>> getReservacionesPorUsuario(int usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'reservaciones',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'created_at DESC',
    );
    return maps.map((row) => Reservacion.fromMap(row)).toList();
  }

  Future<List<Reservacion>> getAllReservaciones() async {
    final db = await database;
    final maps = await db.query('reservaciones', orderBy: 'created_at DESC');
    return maps.map((row) => Reservacion.fromMap(row)).toList();
  }

  Future<int> updateReservacion(Reservacion reservacion) async {
    final db = await database;
    return await db.update(
      'reservaciones',
      reservacion.toMap(),
      where: 'id = ?',
      whereArgs: [reservacion.id],
    );
  }

  Future<int> deleteReservacion(int id) async {
    final db = await database;
    return await db.delete('reservaciones', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

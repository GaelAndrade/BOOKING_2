class Habitacion {
  int? id;
  int hotelId;
  String nombre;
  String descripcion;
  int precio;
  String? imagenUrl;
  int createdAt;

  Habitacion({
    this.id,
    required this.hotelId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'created_at': createdAt,
    };
  }

  factory Habitacion.fromMap(Map<String, dynamic> map) {
    return Habitacion(
      id: map['id'] as int?,
      hotelId: map['hotel_id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      precio: map['precio'] as int,
      imagenUrl: map['imagen_url'] as String?,
      createdAt: map['created_at'] as int,
    );
  }
}

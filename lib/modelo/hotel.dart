class Hotel {
  int? id;
  String nombre;
  String ciudad;
  String? direccion;
  String? descripcion;
  double precioNoche;
  String? imagenUrl;
  double calificacion;
  int? createdAt;

  Hotel({
    this.id,
    required this.nombre,
    required this.ciudad,
    this.direccion,
    this.descripcion,
    required this.precioNoche,
    this.imagenUrl,
    required this.calificacion,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ciudad': ciudad,
      'direccion': direccion,
      'descripcion': descripcion,
      'precio_noche': precioNoche,
      'imagen_url': imagenUrl,
      'calificacion': calificacion,
      'created_at': createdAt,
    };
  }

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      ciudad: map['ciudad'] as String,
      direccion: map['direccion'] as String?,
      descripcion: map['descripcion'] as String?,
      precioNoche: (map['precio_noche'] as num).toDouble(),
      imagenUrl: map['imagen_url'] as String?,
      calificacion: (map['calificacion'] as num).toDouble(),
      createdAt: map['created_at'] as int?,
    );
  }
}

class Reservacion {
  int? id;
  int usuarioId;
  int hotelId;
  String habitacionNombre;
  int fechaEntrada;
  int fechaSalida;
  int huespedes;
  double total;
  String estado;
  int createdAt;

  Reservacion({
    this.id,
    required this.usuarioId,
    required this.hotelId,
    required this.habitacionNombre,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.huespedes,
    required this.total,
    required this.estado,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'hotel_id': hotelId,
      'habitacion_nombre': habitacionNombre,
      'fecha_entrada': fechaEntrada,
      'fecha_salida': fechaSalida,
      'huespedes': huespedes,
      'total': total,
      'estado': estado,
      'created_at': createdAt,
    };
  }

  factory Reservacion.fromMap(Map<String, dynamic> map) {
    return Reservacion(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      hotelId: map['hotel_id'] as int,
      habitacionNombre: map['habitacion_nombre'] as String,
      fechaEntrada: map['fecha_entrada'] as int,
      fechaSalida: map['fecha_salida'] as int,
      huespedes: map['huespedes'] as int,
      total: (map['total'] as num).toDouble(),
      estado: map['estado'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}

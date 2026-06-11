class Usuario {
  int? id;
  String? googleUid;
  String nombre;
  String email;
  String? fotoUrl;
  int createdAt;

  Usuario({
    this.id,
    this.googleUid,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'google_uid': googleUid,
      'nombre': nombre,
      'email': email,
      'foto_url': fotoUrl,
      'created_at': createdAt,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      googleUid: map['google_uid'] as String?,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      fotoUrl: map['foto_url'] as String?,
      createdAt: map['created_at'] as int,
    );
  }
}

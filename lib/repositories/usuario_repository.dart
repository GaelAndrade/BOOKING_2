import '../data/app_database.dart';
import '../data/api_client.dart';
import '../modelo/usuario.dart';

class UsuarioRepository {
  UsuarioRepository._();
  static final UsuarioRepository instance = UsuarioRepository._();

  Future<int> insertUsuario(Usuario usuario) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/usuarios',
        usuario.toMap(),
      );
      final created = Usuario.fromMap(
        Map<String, dynamic>.from(response as Map),
      );
      await _guardarLocal(created);
      return created.id ?? 0;
    } catch (_) {
      return AppDatabase.instance.insertUsuario(usuario);
    }
  }

  Future<Usuario?> getUsuarioPorGoogleUid(String googleUid) async {
    try {
      final usuarios = await _getUsuariosApi();
      for (final usuario in usuarios) {
        await _guardarLocal(usuario);
        if (usuario.googleUid == googleUid) return usuario;
      }
      return null;
    } catch (_) {
      return AppDatabase.instance.getUsuarioPorGoogleUid(googleUid);
    }
  }

  Future<Usuario?> getUsuarioPorEmail(String email) async {
    try {
      final usuarios = await _getUsuariosApi();
      for (final usuario in usuarios) {
        await _guardarLocal(usuario);
        if (usuario.email.toLowerCase() == email.toLowerCase()) {
          return usuario;
        }
      }
      return null;
    } catch (_) {
      return AppDatabase.instance.getUsuarioPorEmail(email);
    }
  }

  Future<Usuario?> getUsuarioPorEmailYPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.instance.post('/api/usuarios/login', {
        'email': email,
        'password': password,
      });
      final usuario = Usuario.fromMap(
        Map<String, dynamic>.from(response as Map),
      );
      await _guardarLocal(usuario);
      return usuario;
    } catch (_) {
      return AppDatabase.instance.getUsuarioPorEmailYPassword(email, password);
    }
  }

  Future<int> updateUsuario(Usuario usuario) async {
    if (usuario.id == null) return 0;
    try {
      final response = await ApiClient.instance.put(
        '/api/usuarios/${usuario.id}',
        usuario.toMap(),
      );
      final updated = Usuario.fromMap(
        Map<String, dynamic>.from(response as Map),
      );
      return _guardarLocal(updated);
    } catch (_) {
      return AppDatabase.instance.updateUsuario(usuario);
    }
  }

  Future<List<Usuario>> _getUsuariosApi() async {
    final response = await ApiClient.instance.get('/api/usuarios') as List;
    return response
        .map((row) => Usuario.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<int> _guardarLocal(Usuario usuario) async {
    if (usuario.id == null) return AppDatabase.instance.insertUsuario(usuario);

    final filasActualizadas = await AppDatabase.instance.updateUsuario(usuario);
    if (filasActualizadas > 0) return filasActualizadas;

    return AppDatabase.instance.insertUsuario(usuario);
  }
}

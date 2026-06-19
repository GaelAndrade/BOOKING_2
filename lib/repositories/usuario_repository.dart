import '../data/app_database.dart';
import '../modelo/usuario.dart';

class UsuarioRepository {
  UsuarioRepository._();
  static final UsuarioRepository instance = UsuarioRepository._();

  Future<int> insertUsuario(Usuario usuario) {
    return AppDatabase.instance.insertUsuario(usuario);
  }

  Future<Usuario?> getUsuarioPorGoogleUid(String googleUid) {
    return AppDatabase.instance.getUsuarioPorGoogleUid(googleUid);
  }

  Future<Usuario?> getUsuarioPorEmail(String email) {
    return AppDatabase.instance.getUsuarioPorEmail(email);
  }

  Future<Usuario?> getUsuarioPorEmailYPassword(String email, String password) {
    return AppDatabase.instance.getUsuarioPorEmailYPassword(email, password);
  }

  Future<int> updateUsuario(Usuario usuario) {
    return AppDatabase.instance.updateUsuario(usuario);
  }
}

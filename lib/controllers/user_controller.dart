// Controlador responsable de la autenticación con Google y de persistir
// el usuario en la base de datos local (SQLite). Expone el usuario actual
// para que otras capas (vistas/controladores) lo consuman.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../modelo/usuario.dart';
import '../repositories/usuario_repository.dart';

class UserController {
  UserController._();
  static final UserController instance = UserController._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Usuario? currentUser;

  // Inicia sesión con Google, guarda/actualiza el usuario en SQLite y
  // guarda la instancia en `currentUser`.
  Future<bool> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return false;

    final existing = await UsuarioRepository.instance.getUsuarioPorGoogleUid(
      user.uid,
    );
    if (existing != null) {
      currentUser = existing;
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final nuevo = Usuario(
      googleUid: user.uid,
      nombre: user.displayName ?? 'Sin nombre',
      email: user.email ?? '',
      createdAt: now,
    );

    final id = await UsuarioRepository.instance.insertUsuario(nuevo);
    nuevo.id = id;
    currentUser = nuevo;
    return true;
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    final user = await UsuarioRepository.instance.getUsuarioPorEmailYPassword(
      email,
      password,
    );
    if (user == null) return false;
    currentUser = user;
    return true;
  }

  Future<bool> registerLocalUser(
    String nombre,
    String email,
    String password,
  ) async {
    final existing = await UsuarioRepository.instance.getUsuarioPorEmail(email);
    if (existing != null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final nuevo = Usuario(
      nombre: nombre,
      email: email,
      password: password,
      createdAt: now,
    );
    final id = await UsuarioRepository.instance.insertUsuario(nuevo);
    nuevo.id = id;
    currentUser = nuevo;
    return true;
  }

  Future<bool> updateCurrentUser({
    String? nombre,
    String? email,
    String? password,
  }) async {
    if (currentUser == null || currentUser!.id == null) return false;
    if (email != null && email != currentUser!.email) {
      final existingEmail = await UsuarioRepository.instance.getUsuarioPorEmail(
        email,
      );
      if (existingEmail != null && existingEmail.id != currentUser!.id) {
        return false;
      }
    }

    final updated = Usuario(
      id: currentUser!.id,
      googleUid: currentUser!.googleUid,
      nombre: nombre ?? currentUser!.nombre,
      email: email ?? currentUser!.email,
      password: password ?? currentUser!.password,
      fotoUrl: currentUser!.fotoUrl,
      createdAt: currentUser!.createdAt,
    );

    final result = await UsuarioRepository.instance.updateUsuario(updated);
    if (result > 0) {
      currentUser = updated;
      return true;
    }
    return false;
  }

  // Asegura que haya un usuario actual persistido y devuelve su id local.
  Future<int?> ensureCurrentUserId() async {
    if (currentUser != null && currentUser!.id != null) return currentUser!.id;

    final fUser = _auth.currentUser;
    if (fUser != null) {
      final dbUser = await UsuarioRepository.instance.getUsuarioPorGoogleUid(
        fUser.uid,
      );
      if (dbUser != null) {
        currentUser = dbUser;
        return dbUser.id;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final nuevo = Usuario(
        googleUid: fUser.uid,
        nombre: fUser.displayName ?? 'Sin nombre',
        email: fUser.email ?? '',
        createdAt: now,
      );
      final id = await UsuarioRepository.instance.insertUsuario(nuevo);
      nuevo.id = id;
      currentUser = nuevo;
      return id;
    }

    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    currentUser = null;
  }
}

import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    await UserController.instance.ensureCurrentUserId();
    final user = UserController.instance.currentUser;
    if (!mounted) return;
    setState(() {
      _nombreController.text = user?.nombre ?? '';
      _emailController.text = user?.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = UserController.instance.currentUser;
    final isGoogleUser = user?.googleUid != null;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'Perfil',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              _profileField(
                label: 'Nombre',
                controller: _nombreController,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              _profileField(
                label: 'Correo',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              _profileField(
                label: isGoogleUser
                    ? 'Contraseña no aplicable para Google'
                    : 'Nueva contraseña',
                controller: _passwordController,
                icon: Icons.lock_outline,
                obscureText: true,
                enabled: !isGoogleUser,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: enabled ? Colors.black26 : Colors.black12,
        width: 1.3,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: TextStyle(
            color: enabled ? AppColors.darkBlue : Colors.black54,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F3F5),
            prefixIcon: Icon(icon, color: AppColors.darkBlue),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: AppColors.lightBlue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await UserController.instance.signOut();
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _saveProfile() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (nombre.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y correo son obligatorios.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    final success = await UserController.instance.updateCurrentUser(
      nombre: nombre,
      email: email,
      password: password.isNotEmpty ? password : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final message = success
        ? 'Perfil actualizado correctamente.'
        : 'Error al actualizar. El correo ya existe.';

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

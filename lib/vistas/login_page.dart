import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'registro_page.dart';
import 'main_page.dart';

//Se define la clase para poder llamarla desde otras partes del codigo
class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); //

  @override
  State<LoginPage> createState() => _LoginPageState(); //
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.black26,
                  backgroundImage: AssetImage('lib/imagenes/codium.jpeg'),
                ),

                const SizedBox(height: 35),

                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                //Aqui se definen los campos de texto para el usuario y la contraseña,
                //asi como el boton de aceptar que navega a la pantalla principal
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                    children: [
                      _inputField(
                        'Correo',
                        false,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        'Contraseña',
                        _obscurePassword,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithCredentials,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                //Aqui se muestra un mensaje para los usuarios que no tienen cuenta,
                //con un enlace para registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, //Aqui centramos el texto y el enlace
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      //El GestureDetector se encarga de detectar el toque en el texto "Regístrate" para navegar a la pantalla de registro
                      onTap: () {
                        Navigator.push(
                          //Se navega a la pantalla de registro al hacer clic en "Regístrate"
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroPage(),
                          ),
                        );
                      },
                      child: const Text(
                        //El boton viene siendo el texto resaltado en color amarillo y no un boton como tal
                        'Regístrate',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),
                //Aqui se define el boton para iniciar sesión con Google,
                //si el usuario ya ha iniciado sesión con Google, se muestra un indicador de carga en
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata, size: 32),
                    label: Text(
                      _isLoading ? 'Cargando...' : 'Continuar con Google',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Aqui se define el widget para los campos de texto,
  //que se reutiliza para el usuario y la contraseña
  //Mas que nada estetuco para cuidar la informacion del usuario al momento de ingresarlo
  Widget _inputField(
    String hint,
    bool isPassword, {
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Future<void> _signInWithCredentials() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa correo y contraseña.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await UserController.instance.signInWithEmailPassword(
        email,
        password,
      );
      if (!mounted) return;

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (success) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Llama al UserController para iniciar sesión con Google y persistir el usuario.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await UserController.instance.signInWithGoogle();
      if (!mounted) return;

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (success) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión cancelado o fallido.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

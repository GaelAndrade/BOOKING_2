import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 50),

                const CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.black26,
                  child: Text(
                    'NEOINN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                    children: [
                      _inputField('Nombre', false),
                      const SizedBox(height: 14),
                      _inputField('Correo', false),
                      const SizedBox(height: 14),
                      _inputField('Contraseña', true),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Registrarse'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, bool isPassword) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}

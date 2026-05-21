import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_navbar.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  // Datos de ejemplo
  final String nombre = 'Juan Pérez';
  final String correo = 'juan.perez@example.com';
  final String rol = 'Cliente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Nombre: $nombre', style: const TextStyle(fontSize: 18)),
                Text('Correo: $correo', style: const TextStyle(fontSize: 18)),
                Text('Rol: $rol', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción cerrar sesión
                    },
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 2, onTap: (index) {}),
    );
  }
}

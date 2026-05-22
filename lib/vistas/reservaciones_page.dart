import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_navbar.dart';

class ReservacionesPage extends StatelessWidget {
  const ReservacionesPage({super.key});

  // Datos de ejemplo (provisional)
  final List<Map<String, String>> reservaciones = const [
    {
      'hotel': 'Hotel Salinas',
      'habitacion': 'Habitación doble',
      'fecha': '12/06/2026 - 15/06/2026',
      'total': '3600 MXN',
      'estado': 'Confirmada',
    },
    {
      'hotel': 'La Quinta',
      'habitacion': 'Habitación matrimonial',
      'fecha': '20/06/2026 - 22/06/2026',
      'total': '2100 MXN',
      'estado': 'Confirmada',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(22),
            itemCount: reservaciones.length,
            itemBuilder: (context, index) {
              final reserva = reservaciones[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva['hotel']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Habitación: ${reserva['habitacion']}'),
                    Text('Fechas: ${reserva['fecha']}'),
                    Text('Total: ${reserva['total']}'),
                    const SizedBox(height: 8),
                    Text('Estado: ${reserva['estado']}'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      //bottomNavigationBar: CustomNavbar(currentIndex: 1, onTap: (index) {}),
    );
  }
}

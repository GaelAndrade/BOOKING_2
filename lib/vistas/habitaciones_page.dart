import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'reservacion_page.dart';

class HabitacionesPage extends StatefulWidget {
  final Hotel hotel;

  const HabitacionesPage({super.key, required this.hotel});

  @override
  State<HabitacionesPage> createState() => _HabitacionesPageState();
}

class _HabitacionesPageState extends State<HabitacionesPage> {
  late final Future<List<Habitacion>> _habitacionesFuture;

  @override
  void initState() {
    super.initState();
    _habitacionesFuture = widget.hotel.id != null
        ? HotelController.instance.getRoomsForHotel(widget.hotel.id!)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<List<Habitacion>>(
            future: _habitacionesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                );
              }

              final habitaciones = snapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Habitaciones',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.hotel.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 25),
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Error al cargar habitaciones: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else if (habitaciones.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No hay habitaciones disponibles para este hotel.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    ...habitaciones.map(
                      (habitacion) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _habitacionCard(context, habitacion),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      //bottomNavigationBar: CustomNavbar(currentIndex: 0, onTap: (index) {}),
    );
  }

  Widget _habitacionCard(BuildContext context, Habitacion habitacion) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habitacion.imagenUrl != null && habitacion.imagenUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                habitacion.imagenUrl!,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habitacion.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  habitacion.descripcion,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppColors.darkBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${habitacion.precio} MXN por noche',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservacionPage(
                            nombreHotel: widget.hotel.nombre,
                            nombreHabitacion: habitacion.nombre,
                            precioPorNoche: habitacion.precio,
                          ),
                        ),
                      );
                    },
                    child: const Text('Reservar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_navbar.dart';
import 'reservacion_page.dart';

class HabitacionesPage extends StatelessWidget {
  final String nombreHotel;

  const HabitacionesPage({super.key, required this.nombreHotel});

  @override
  Widget build(BuildContext context) {
    final habitaciones = _obtenerHabitaciones(nombreHotel);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
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
                nombreHotel,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 25),

              ...habitaciones.map(
                (habitacion) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _habitacionCard(
                    context,
                    nombre: habitacion.nombre,
                    descripcion: habitacion.descripcion,
                    precio: habitacion.precio,
                    imagen: habitacion.imagen,
                    servicios: habitacion.servicios,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 0, onTap: (index) {}),
    );
  }

  List<HabitacionHotel> _obtenerHabitaciones(String hotel) {
    switch (hotel) {
      case 'Hotel Salinas':
        return const [
          HabitacionHotel(
            nombre: 'Habitación doble',
            descripcion:
                'Habitación con dos camas matrimoniales, baño privado, ropa de cama de alta calidad y cafetera.',
            precio: 1200,
            imagen: 'lib/imagenes/salinas_doble.png',
            servicios: [
              Icons.wifi,
              Icons.ac_unit,
              Icons.local_cafe,
              Icons.bathtub,
            ],
          ),
          HabitacionHotel(
            nombre: 'Suite familiar',
            descripcion:
                'Espacio amplio para familias, con área de descanso, televisión y acceso a servicios del hotel.',
            precio: 1750,
            imagen: 'lib/imagenes/salinas_familiar.png',
            servicios: [Icons.wifi, Icons.tv, Icons.room_service, Icons.pool],
          ),
        ];

      case 'Poza Rica Inn':
        return const [
          HabitacionHotel(
            nombre: 'Habitación ejecutiva',
            descripcion:
                'Diseñada para viajes de trabajo, cuenta con escritorio, cama king size y ambiente cómodo.',
            precio: 1900,
            imagen: 'lib/imagenes/poza_ejec.jpg',
            servicios: [
              Icons.wifi,
              Icons.desk,
              Icons.ac_unit,
              Icons.local_parking,
            ],
          ),
          HabitacionHotel(
            nombre: 'Suite premium',
            descripcion:
                'Suite amplia con cama king size, zona de estar, servicio a la habitación y acceso a gimnasio.',
            precio: 2600,
            imagen: 'lib/imagenes/poza_suite.jpg',
            servicios: [
              Icons.wifi,
              Icons.fitness_center,
              Icons.room_service,
              Icons.king_bed,
            ],
          ),
        ];

      case 'La Quinta':
        return const [
          HabitacionHotel(
            nombre: 'Habitación estándar',
            descripcion:
                'Habitación cómoda para estancias cortas, con baño privado, aire acondicionado y televisión.',
            precio: 850,
            imagen: 'lib/imagenes/la_quinta_estandar.jpg',
            servicios: [Icons.wifi, Icons.ac_unit, Icons.tv],
          ),
          HabitacionHotel(
            nombre: 'Habitación matrimonial',
            descripcion:
                'Opción práctica para dos personas, con cama matrimonial, baño privado y servicio básico.',
            precio: 1050,
            imagen: 'lib/imagenes/la_quinta_matrimonial.jpg',
            servicios: [Icons.wifi, Icons.bed, Icons.local_parking],
          ),
        ];

      case 'Hotel Paris':
        return const [
          HabitacionHotel(
            nombre: 'Habitación sencilla',
            descripcion:
                'Habitación económica para una persona, ideal para una noche o estancia breve.',
            precio: 650,
            imagen: 'lib/imagenes/paris_sencilla.jpg',
            servicios: [Icons.wifi, Icons.tv, Icons.bed],
          ),
          HabitacionHotel(
            nombre: 'Habitación doble',
            descripcion:
                'Habitación sencilla con dos camas, baño privado y servicios básicos para hospedaje accesible.',
            precio: 900,
            imagen: 'lib/imagenes/paris_doble_economica.jpg',
            servicios: [Icons.wifi, Icons.bathtub, Icons.tv],
          ),
        ];

      case 'Hotel Victoria':
        return const [
          HabitacionHotel(
            nombre: 'Habitación confort',
            descripcion:
                'Habitación tranquila con cama matrimonial, baño privado y ambiente familiar.',
            precio: 980,
            imagen: 'lib/imagenes/victoria_confort.jpg',
            servicios: [Icons.wifi, Icons.ac_unit, Icons.security],
          ),
          HabitacionHotel(
            nombre: 'Habitación familiar',
            descripcion:
                'Espacio amplio para familias, con camas dobles, televisión y estacionamiento incluido.',
            precio: 1450,
            imagen: 'lib/imagenes/victoria_familiar.jpg',
            servicios: [
              Icons.wifi,
              Icons.tv,
              Icons.local_parking,
              Icons.restaurant,
            ],
          ),
        ];

      default:
        return const [];
    }
  }

  Widget _habitacionCard(
    BuildContext context, {
    required String nombre,
    required String descripcion,
    required int precio,
    required String imagen,
    required List<IconData> servicios,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagen,
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
                  nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(descripcion, style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 12),

                Row(
                  children: servicios
                      .map(
                        (icono) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            icono,
                            color: AppColors.darkBlue,
                            size: 24,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 12),

                Text(
                  '\$$precio MXN por noche',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservacionPage(
                            nombreHotel: nombreHotel,
                            nombreHabitacion: nombre,
                            precioPorNoche: precio,
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

class HabitacionHotel {
  final String nombre;
  final String descripcion;
  final int precio;
  final String imagen;
  final List<IconData> servicios;

  const HabitacionHotel({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.servicios,
  });
}

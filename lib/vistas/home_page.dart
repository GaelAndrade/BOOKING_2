import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_navbar.dart';
import 'detalle_hotel_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ListView(
              children: [
                const Text(
                  'Hola, ¿cómo estás?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                _hotelCard(
                  context,
                  nombre: 'Hotel Salinas',
                  direccion: 'Boulevard Adolfo Ruiz Cortinez',
                  imagen: 'lib/imagenes/hotel_salinas.jpg',
                  estrellas: 4,
                  descripcion:
                      'Hotel Salinas ofrece una estancia cómoda cerca del boulevard Adolfo Ruiz Cortinez. Es una opción ideal para viajes familiares, descanso o visitas de trabajo dentro de la ciudad.',
                  servicios: const [
                    ServicioHotel(icono: Icons.pool, texto: 'Alberca'),
                    ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
                    ServicioHotel(
                      icono: Icons.restaurant,
                      texto: 'Restaurante',
                    ),
                    ServicioHotel(
                      icono: Icons.local_parking,
                      texto: 'Estacionamiento',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _hotelCard(
                  context,
                  nombre: 'Poza Rica Inn',
                  direccion: 'Blvd. Adolfo Ruiz Cortines',
                  imagen: 'lib/imagenes/poza_rica_inn.jpg',
                  estrellas: 5,
                  descripcion:
                      'Poza Rica Inn está orientado a huéspedes que buscan comodidad, buena ubicación y servicios completos. Es adecuado para estancias ejecutivas, eventos y visitas prolongadas.',
                  servicios: const [
                    ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
                    ServicioHotel(icono: Icons.pool, texto: 'Alberca'),
                    ServicioHotel(
                      icono: Icons.fitness_center,
                      texto: 'Gimnasio',
                    ),
                    ServicioHotel(
                      icono: Icons.restaurant_menu,
                      texto: 'Desayuno',
                    ),
                    ServicioHotel(icono: Icons.meeting_room, texto: 'Salones'),
                  ],
                ),

                const SizedBox(height: 20),

                _hotelCard(
                  context,
                  nombre: 'La Quinta',
                  direccion: 'Zona centro de Poza Rica',
                  imagen: 'lib/imagenes/la_quinta.png',
                  estrellas: 4,
                  descripcion:
                      'La Quinta ofrece hospedaje práctico y accesible en una zona céntrica. Es una alternativa conveniente para quienes necesitan movilidad rápida dentro de Poza Rica.',
                  servicios: const [
                    ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
                    ServicioHotel(
                      icono: Icons.local_parking,
                      texto: 'Estacionamiento',
                    ),
                    ServicioHotel(
                      icono: Icons.ac_unit,
                      texto: 'Aire acondicionado',
                    ),
                    ServicioHotel(
                      icono: Icons.room_service,
                      texto: 'Servicio a cuarto',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _hotelCard(
                  context,
                  nombre: 'Hotel Paris',
                  direccion: 'Av. Principal, Poza Rica',
                  imagen: 'lib/imagenes/hotel_paris.jpg',
                  estrellas: 3,
                  descripcion:
                      'Hotel Paris es una opción sencilla para estancias cortas. Su ubicación permite acceder fácilmente a comercios, transporte y puntos importantes de la ciudad.',
                  servicios: const [
                    ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
                    ServicioHotel(icono: Icons.tv, texto: 'Televisión'),
                    ServicioHotel(
                      icono: Icons.bed,
                      texto: 'Habitaciones cómodas',
                    ),
                    ServicioHotel(icono: Icons.local_cafe, texto: 'Cafetería'),
                  ],
                ),

                const SizedBox(height: 20),

                _hotelCard(
                  context,
                  nombre: 'Hotel Victoria',
                  direccion: 'Col. Obrera, Poza Rica',
                  imagen: 'lib/imagenes/hotel_victoria.jpeg',
                  estrellas: 4,
                  descripcion:
                      'Hotel Victoria combina comodidad y ambiente familiar. Es una opción útil para visitantes que buscan tranquilidad, atención personalizada y buena relación precio-servicio.',
                  servicios: const [
                    ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
                    ServicioHotel(
                      icono: Icons.local_parking,
                      texto: 'Estacionamiento',
                    ),
                    ServicioHotel(
                      icono: Icons.restaurant,
                      texto: 'Restaurante',
                    ),
                    ServicioHotel(icono: Icons.security, texto: 'Seguridad'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: CustomNavbar(currentIndex: 0, onTap: (index) {}),
    );
  }

  Widget _hotelCard(
    BuildContext context, {
    required String nombre,
    required String direccion,
    required String imagen,
    required int estrellas,
    required String descripcion,
    required List<ServicioHotel> servicios,
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

                const SizedBox(height: 6),

                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < estrellas ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.darkBlue,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        direccion,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleHotelPage(
                            nombre: nombre,
                            direccion: direccion,
                            imagen: imagen,
                            estrellas: estrellas,
                            descripcion: descripcion,
                            servicios: servicios,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver detalles'),
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

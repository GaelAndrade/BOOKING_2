import 'package:flutter/material.dart';
import '../modelo/hotel.dart';
import '../modelo/servicio_hotel.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'habitaciones_page.dart';

class DetalleHotelPage extends StatefulWidget {
  final Hotel hotel;

  const DetalleHotelPage({super.key, required this.hotel});

  @override
  State<DetalleHotelPage> createState() => _DetalleHotelPageState();
}

class _DetalleHotelPageState extends State<DetalleHotelPage> {
  int imagenActual = 0;

  late final List<String> imagenesHotel = _obtenerImagenesHotel(
    widget.hotel.nombre,
  );

  List<String> _obtenerImagenesHotel(String hotel) {
    switch (hotel) {
      case 'Hotel Salinas':
        return [
          'lib/imagenes/salinas_1.jpg',
          'lib/imagenes/salinas_2.jpg',
          'lib/imagenes/salinas_3.jpg',
        ];
      case 'Poza Rica Inn':
        return [
          'lib/imagenes/poza_rica_inn_1.jpg',
          'lib/imagenes/poza_rica_inn_2.jpg',
          'lib/imagenes/poza_rica_inn_3.jpg',
        ];
      case 'La Quinta':
        return [
          'lib/imagenes/la_quinta_1.jpg',
          'lib/imagenes/la_quinta_2.jpg',
          'lib/imagenes/la_quinta_3.jpg',
        ];
      case 'Hotel Paris':
        return [
          'lib/imagenes/paris_1.jpg',
          'lib/imagenes/paris_2.png',
          'lib/imagenes/paris_3.jpg',
        ];
      case 'Hotel Victoria':
        return [
          'lib/imagenes/victoria_1.jpg',
          'lib/imagenes/victoria_2.jpg',
          'lib/imagenes/victoria_3.jpg',
        ];
      default:
        return [widget.hotel.imagenUrl ?? 'lib/imagenes/hotel_salinas.jpg'];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      widget.hotel.nombre,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 230,
                child: PageView.builder(
                  itemCount: imagenesHotel.length,
                  onPageChanged: (index) {
                    setState(() {
                      imagenActual = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagenesHotel[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imagenesHotel.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: imagenActual == index ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: imagenActual == index
                          ? AppColors.darkBlue
                          : Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < widget.hotel.calificacion.toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.darkBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.hotel.direccion ?? widget.hotel.ciudad,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Información de la propiedad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.hotel.descripcion ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Servicios',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _hotelServices(widget.hotel.nombre)
                          .map(
                            (servicio) => _ServicioItem(
                              icono: servicio.icono,
                              texto: servicio.texto,
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HabitacionesPage(hotel: widget.hotel),
                            ),
                          );
                        },
                        child: const Text(
                          'Ver habitaciones',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //bottomNavigationBar: CustomNavbar(currentIndex: 0, onTap: (index),
    );
  }
}

class _ServicioItem extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ServicioItem({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.darkBlue, size: 30),
          const SizedBox(height: 6),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

List<ServicioHotel> _hotelServices(String nombre) {
  switch (nombre) {
    case 'Hotel Salinas':
      return const [
        ServicioHotel(icono: Icons.pool, texto: 'Alberca'),
        ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
        ServicioHotel(icono: Icons.restaurant, texto: 'Restaurante'),
        ServicioHotel(icono: Icons.local_parking, texto: 'Estacionamiento'),
      ];
    case 'Poza Rica Inn':
      return const [
        ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
        ServicioHotel(icono: Icons.pool, texto: 'Alberca'),
        ServicioHotel(icono: Icons.fitness_center, texto: 'Gimnasio'),
        ServicioHotel(icono: Icons.restaurant_menu, texto: 'Desayuno'),
        ServicioHotel(icono: Icons.meeting_room, texto: 'Salones'),
      ];
    case 'La Quinta':
      return const [
        ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
        ServicioHotel(icono: Icons.local_parking, texto: 'Estacionamiento'),
        ServicioHotel(icono: Icons.ac_unit, texto: 'Aire acondicionado'),
        ServicioHotel(icono: Icons.room_service, texto: 'Servicio a cuarto'),
      ];
    case 'Hotel Paris':
      return const [
        ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
        ServicioHotel(icono: Icons.tv, texto: 'Televisión'),
        ServicioHotel(icono: Icons.bed, texto: 'Habitaciones cómodas'),
        ServicioHotel(icono: Icons.local_cafe, texto: 'Cafetería'),
      ];
    case 'Hotel Victoria':
      return const [
        ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis'),
        ServicioHotel(icono: Icons.local_parking, texto: 'Estacionamiento'),
        ServicioHotel(icono: Icons.restaurant, texto: 'Restaurante'),
        ServicioHotel(icono: Icons.security, texto: 'Seguridad'),
      ];
    default:
      return const [ServicioHotel(icono: Icons.wifi, texto: 'Wifi gratis')];
  }
}

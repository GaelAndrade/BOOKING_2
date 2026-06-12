import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../controllers/user_controller.dart';
import '../modelo/hotel.dart';
import '../modelo/servicio_hotel.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'detalle_hotel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = 'Hola';
  bool _isLoading = true;
  List<Hotel> _hoteles = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadHotels();
  }

  Future<void> _loadUser() async {
    await UserController.instance.ensureCurrentUserId();
    final user = UserController.instance.currentUser;
    final name = user?.nombre ?? '';
    final first = name
        .split(' ')
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (!mounted) return;
    setState(() {
      _firstName = first.isNotEmpty ? first : 'Usuario';
    });
  }

  Future<void> _loadHotels() async {
    final hoteles = await HotelController.instance.getHotels();
    if (!mounted) return;
    setState(() {
      _hoteles = hoteles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Hola, $_firstName 👋',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'lib/imagenes/codium.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_hoteles.isEmpty)
                  const Center(
                    child: Text(
                      'No se encontraron hoteles.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                else
                  ..._hoteles.map(
                    (hotel) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _hotelCard(context, hotel: hotel),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hotelCard(BuildContext context, {required Hotel hotel}) {
    final imagen = hotel.imagenUrl?.isNotEmpty == true
        ? hotel.imagenUrl!
        : _hotelImageAsset(hotel.nombre);

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
                  hotel.nombre,
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
                      index < hotel.calificacion
                          ? Icons.star
                          : Icons.star_border,
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
                        hotel.direccion ?? hotel.ciudad,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  hotel.descripcion ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleHotelPage(hotel: hotel),
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

  String _hotelImageAsset(String nombre) {
    switch (nombre) {
      case 'Hotel Salinas':
        return 'lib/imagenes/hotel_salinas.jpg';
      case 'Poza Rica Inn':
        return 'lib/imagenes/poza_rica_inn.jpg';
      case 'La Quinta':
        return 'lib/imagenes/la_quinta.png';
      case 'Hotel Paris':
        return 'lib/imagenes/hotel_paris.jpg';
      case 'Hotel Victoria':
        return 'lib/imagenes/hotel_victoria.jpeg';
      default:
        return 'lib/imagenes/hotel_salinas.jpg';
    }
  }

  // ignore: unused_element
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
}

import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../data/app_database.dart';
import '../modelo/reservacion.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'reservacion_page.dart';

class ReservacionesPage extends StatefulWidget {
  const ReservacionesPage({super.key});

  @override
  State<ReservacionesPage> createState() => _ReservacionesPageState();
}

class _ReservacionesPageState extends State<ReservacionesPage> {
  bool _isLoading = true;
  List<Reservacion> _reservaciones = [];
  Map<int, String> _hotelNombres = {};

  @override
  void initState() {
    super.initState();
    _cargarReservaciones();
  }

  Future<void> _cargarReservaciones() async {
    final usuarioId = await UserController.instance.ensureCurrentUserId();
    final reservas = usuarioId != null
        ? await AppDatabase.instance.getReservacionesPorUsuario(usuarioId)
        : <Reservacion>[];
    final hoteles = await AppDatabase.instance.getAllHotels();

    if (!mounted) return;
    setState(() {
      _reservaciones = reservas;
      _hotelNombres = {
        for (final hotel in hoteles)
          if (hotel.id != null) hotel.id!: hotel.nombre,
      };
      _isLoading = false;
    });
  }

  String _formatearFecha(int timestamp) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reservaciones.isEmpty
              ? const Center(
                  child: Text(
                    'No hay reservaciones guardadas.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(22),
                  itemCount: _reservaciones.length,
                  itemBuilder: (context, index) {
                    final reserva = _reservaciones[index];
                    final hotelNombre =
                        _hotelNombres[reserva.hotelId] ??
                        'Hotel ${reserva.hotelId}';
                    final fecha =
                        '${_formatearFecha(reserva.fechaEntrada)} - ${_formatearFecha(reserva.fechaSalida)}';
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
                            hotelNombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Habitación: ${reserva.habitacionNombre}'),
                          Text('Fechas: $fecha'),
                          Text(
                            'Total: ${reserva.total.toStringAsFixed(2)} MXN',
                          ),
                          const SizedBox(height: 8),
                          Text('Estado: ${reserva.estado}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final navigator = Navigator.of(context);
                                  final hotel = await AppDatabase.instance
                                      .getHotelPorId(reserva.hotelId);
                                  if (hotel == null || hotel.id == null) {
                                    return;
                                  }
                                  final habitacion = await AppDatabase.instance
                                      .getHabitacionPorHotelYNombre(
                                        reserva.hotelId,
                                        reserva.habitacionNombre,
                                      );
                                  if (!mounted) return;
                                  if (habitacion == null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se encontró la habitación para editar.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!mounted) return;
                                  final updated = await navigator.push<bool?>(
                                    MaterialPageRoute(
                                      builder: (_) => ReservacionPage(
                                        nombreHotel: hotel.nombre,
                                        nombreHabitacion:
                                            reserva.habitacionNombre,
                                        precioPorNoche: habitacion.precio,
                                        reservacion: reserva,
                                      ),
                                    ),
                                  );
                                  if (updated == true) {
                                    _cargarReservaciones();
                                  }
                                },
                                child: const Text('Editar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

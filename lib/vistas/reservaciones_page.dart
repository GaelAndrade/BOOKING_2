import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../modelo/reservacion.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

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
    final reservas = await AppDatabase.instance.getAllReservaciones();
    final hoteles = await AppDatabase.instance.getAllHotels();

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

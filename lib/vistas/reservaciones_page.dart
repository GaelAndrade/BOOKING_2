import 'package:flutter/material.dart';
import '../controllers/reservacion_controller.dart';
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
    final reservas = await ReservacionController.instance
        .getReservacionesUsuarioActual();
    final hotelNombres = await ReservacionController.instance
        .getNombresHotelesPorId();

    if (!mounted) return;
    setState(() {
      _reservaciones = reservas;
      _hotelNombres = hotelNombres;
      _isLoading = false;
    });
  }

  String _formatearFecha(int timestamp) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  int _numeroNoches(Reservacion reserva) {
    final entrada = DateTime.fromMillisecondsSinceEpoch(reserva.fechaEntrada);
    final salida = DateTime.fromMillisecondsSinceEpoch(reserva.fechaSalida);
    final noches = salida.difference(entrada).inDays;
    return noches > 0 ? noches : 0;
  }

  Future<void> _editarReservacion(Reservacion reserva) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ReservacionController.instance;

    final hotel = await controller.getHotelPorId(reserva.hotelId);
    if (hotel == null || hotel.id == null) return;

    final habitacion = await controller.getHabitacionPorHotelYNombre(
      reserva.hotelId,
      reserva.habitacionNombre,
    );
    if (!mounted) return;

    if (habitacion == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se encontró la habitación para editar.'),
        ),
      );
      return;
    }

    final updated = await navigator.push<bool?>(
      MaterialPageRoute(
        builder: (_) => ReservacionPage(
          nombreHotel: hotel.nombre,
          nombreHabitacion: reserva.habitacionNombre,
          precioPorNoche: habitacion.precio,
          reservacion: reserva,
        ),
      ),
    );
    if (updated == true) {
      _cargarReservaciones();
    }
  }

  Future<void> _confirmarEliminarReservacion(Reservacion reserva) async {
    if (reserva.id == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reservación'),
        content: const Text(
          '¿Seguro que quieres eliminar esta reservación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final eliminado = await ReservacionController.instance.eliminarReservacion(
      reserva.id!,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          eliminado
              ? 'Reservación eliminada.'
              : 'No se pudo eliminar la reservación.',
        ),
      ),
    );

    if (eliminado) {
      _cargarReservaciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                )
              : ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Mis reservas',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_reservaciones.isNotEmpty)
                          _CountBadge(count: _reservaciones.length),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Consulta y administra tus próximas estancias.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_reservaciones.isEmpty)
                      const _EmptyReservations()
                    else
                      ..._reservaciones.asMap().entries.map((entry) {
                        final index = entry.key;
                        final reserva = entry.value;
                        final hotelNombre =
                            _hotelNombres[reserva.hotelId] ??
                            'Hotel ${reserva.hotelId}';
                        return _AnimatedReservationCard(
                          index: index,
                          child: _ReservationCard(
                            reserva: reserva,
                            hotelNombre: hotelNombre,
                            entrada: _formatearFecha(reserva.fechaEntrada),
                            salida: _formatearFecha(reserva.fechaSalida),
                            noches: _numeroNoches(reserva),
                            onEdit: () => _editarReservacion(reserva),
                            onDelete: () =>
                                _confirmarEliminarReservacion(reserva),
                          ),
                        );
                      }),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AnimatedReservationCard extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedReservationCard({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index * 45).clamp(0, 180)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: const [
          Icon(Icons.calendar_month_outlined, color: Colors.white, size: 58),
          SizedBox(height: 14),
          Text(
            'No hay reservaciones guardadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando reserves una habitación, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservacion reserva;
  final String hotelNombre;
  final String entrada;
  final String salida;
  final int noches;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReservationCard({
    required this.reserva,
    required this.hotelNombre,
    required this.entrada,
    required this.salida,
    required this.noches,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hotelNombre,
                  style: const TextStyle(
                    color: Color(0xFF1D2530),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(estado: reserva.estado),
            ],
          ),
          const SizedBox(height: 14),
          _InfoLine(icon: Icons.bed_outlined, text: reserva.habitacionNombre),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.people_outline,
            text:
                '${reserva.huespedes} ${reserva.huespedes == 1 ? 'huésped' : 'huéspedes'}',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateColumn(label: 'Entrada', value: entrada),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateColumn(label: 'Salida', value: salida),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoLine(
                  icon: Icons.nights_stay_outlined,
                  text: '$noches ${noches == 1 ? 'noche' : 'noches'}',
                ),
              ),
              Text(
                '${reserva.total.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String estado;

  const _StatusChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mediumBlue),
      ),
      child: Text(
        estado,
        style: const TextStyle(
          color: AppColors.darkBlue,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkBlue, size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF26313D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1D2530),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../data/app_database.dart';
import '../controllers/user_controller.dart';
import '../modelo/reservacion.dart';

class ReservacionPage extends StatefulWidget {
  final String nombreHotel;
  final String nombreHabitacion;
  final int precioPorNoche;
  final Reservacion? reservacion;

  const ReservacionPage({
    super.key,
    required this.nombreHotel,
    required this.nombreHabitacion,
    required this.precioPorNoche,
    this.reservacion,
  });

  @override
  State<ReservacionPage> createState() => _ReservacionPageState();
}

class _ReservacionPageState extends State<ReservacionPage> {
  DateTime? fechaEntrada;
  DateTime? fechaSalida;

  // Variables para tarjeta
  String nombreTitular = '';
  String numeroTarjeta = '';
  String expiracion = '';
  String cvv = '';
  final TextEditingController _expiracionController = TextEditingController();

  bool get isEditing => widget.reservacion != null;

  int get numeroNoches {
    if (fechaEntrada == null || fechaSalida == null) return 0;
    final diferencia = fechaSalida!.difference(fechaEntrada!).inDays;
    return diferencia > 0 ? diferencia : 0;
  }

  int get total {
    return numeroNoches * widget.precioPorNoche;
  }

  Future<void> _seleccionarFechaEntrada() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (fecha != null) {
      setState(() {
        fechaEntrada = fecha;
        if (fechaSalida != null && fechaSalida!.isBefore(fechaEntrada!)) {
          fechaSalida = null;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      fechaEntrada = DateTime.fromMillisecondsSinceEpoch(
        widget.reservacion!.fechaEntrada,
      );
      fechaSalida = DateTime.fromMillisecondsSinceEpoch(
        widget.reservacion!.fechaSalida,
      );
    }
  }

  @override
  void dispose() {
    _expiracionController.dispose();
    super.dispose();
  }

  String _formatExpiration(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final month = digits.substring(0, min(2, digits.length));
    final year = digits.length > 2
        ? digits.substring(2, min(4, digits.length))
        : '';
    return year.isEmpty ? month : '$month/$year';
  }

  void _onExpiracionChanged(String value) {
    final formatted = _formatExpiration(value);
    if (formatted != value) {
      _expiracionController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {
      expiracion = formatted;
    });
  }

  Future<void> _seleccionarFechaSalida() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate:
          fechaEntrada?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate:
          fechaEntrada?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );

    if (fecha != null) {
      setState(() {
        fechaSalida = fecha;
      });
    }
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> _confirmarReservacion() async {
    if (fechaEntrada == null || fechaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha de entrada y salida.')),
      );
      return;
    }

    if (nombreTitular.isEmpty ||
        numeroTarjeta.isEmpty ||
        expiracion.isEmpty ||
        cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los datos de la tarjeta.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Se busca el hotel en la base de datos usando el nombre que se recibe desde la página de habitaciones.
    final hotel = await AppDatabase.instance.getHotelPorNombre(
      widget.nombreHotel,
    );
    if (hotel == null || hotel.id == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se encontró el hotel en la base de datos.'),
        ),
      );
      return;
    }

    // Obtener/asegurar usuario actual y luego insertar la reservación en SQLite.
    final usuarioId = await UserController.instance.ensureCurrentUserId();
    if (usuarioId == null) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Inicia sesión antes de reservar.')),
      );
      return;
    }

    final reservacion = Reservacion(
      id: widget.reservacion?.id,
      usuarioId: usuarioId,
      hotelId: hotel.id!,
      habitacionNombre: widget.nombreHabitacion,
      fechaEntrada: fechaEntrada!.millisecondsSinceEpoch,
      fechaSalida: fechaSalida!.millisecondsSinceEpoch,
      huespedes: 1,
      total: total.toDouble(),
      estado: widget.reservacion?.estado ?? 'confirmada',
      createdAt:
          widget.reservacion?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
    );

    if (isEditing) {
      await AppDatabase.instance.updateReservacion(reservacion);
    } else {
      await AppDatabase.instance.insertReservacion(reservacion);
    }

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Reservación actualizada.'
              : 'Reservación guardada en la base de datos.',
        ),
      ),
    );
    navigator.pop(true);
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
                  const Expanded(
                    child: Text(
                      'Reservación',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                    const Text(
                      'Detalles de la reservación',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _infoRow('Hotel', widget.nombreHotel),
                    _infoRow('Habitación', widget.nombreHabitacion),
                    _infoRow(
                      'Precio por noche',
                      '\$${widget.precioPorNoche} MXN',
                    ),

                    const SizedBox(height: 22),

                    _fechaButton(
                      titulo: 'Fecha de entrada',
                      valor: _formatearFecha(fechaEntrada),
                      onPressed: _seleccionarFechaEntrada,
                    ),

                    const SizedBox(height: 14),

                    _fechaButton(
                      titulo: 'Fecha de salida',
                      valor: _formatearFecha(fechaSalida),
                      onPressed: _seleccionarFechaSalida,
                    ),

                    const SizedBox(height: 22),

                    _infoRow('Número de noches', '$numeroNoches'),
                    _infoRow('Total', '\$$total MXN'),

                    const SizedBox(height: 25),

                    // --- Sección para ingresar tarjeta ---
                    const Text(
                      'Método de pago',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nombre del titular',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          nombreTitular = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Número de tarjeta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      onChanged: (value) {
                        setState(() {
                          numeroTarjeta = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiracionController,
                            decoration: InputDecoration(
                              labelText: 'MM/AA',
                              hintText: 'MM/AA',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            onChanged: _onExpiracionChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            onChanged: (value) {
                              setState(() {
                                cvv = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmarReservacion,
                        child: Text(
                          isEditing
                              ? 'Actualizar reservación'
                              : 'Confirmar reservación',
                          style: const TextStyle(fontSize: 18),
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
      //bottomNavigationBar: CustomNavbar(currentIndex: 1, onTap: (index) {}),
    );
  }

  Widget _infoRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _fechaButton({
    required String titulo,
    required String valor,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.calendar_month),
            label: Text(valor),
          ),
        ),
      ],
    );
  }
}

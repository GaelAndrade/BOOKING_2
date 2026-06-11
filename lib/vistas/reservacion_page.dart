import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../data/app_database.dart';
import '../modelo/reservacion.dart';

class ReservacionPage extends StatefulWidget {
  final String nombreHotel;
  final String nombreHabitacion;
  final int precioPorNoche;

  const ReservacionPage({
    super.key,
    required this.nombreHotel,
    required this.nombreHabitacion,
    required this.precioPorNoche,
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

    // Se busca el hotel en la base de datos usando el nombre que se recibe desde la página de habitaciones.
    final hotel = await AppDatabase.instance.getHotelPorNombre(
      widget.nombreHotel,
    );
    if (hotel == null || hotel.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el hotel en la base de datos.'),
        ),
      );
      return;
    }

    // Insertar la reservación en SQLite.
    final nuevaReservacion = Reservacion(
      usuarioId:
          1, // Usuario local temporal hasta que se integre autenticación.
      hotelId: hotel.id!,
      habitacionNombre: widget.nombreHabitacion,
      fechaEntrada: fechaEntrada!.millisecondsSinceEpoch,
      fechaSalida: fechaSalida!.millisecondsSinceEpoch,
      huespedes: 1,
      total: total.toDouble(),
      estado: 'confirmada',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await AppDatabase.instance.insertReservacion(nuevaReservacion);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reservación guardada en la base de datos.'),
      ),
    );
    Navigator.pop(context);
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
                            decoration: InputDecoration(
                              labelText: 'MM/AA',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.datetime,
                            maxLength: 5,
                            onChanged: (value) {
                              setState(() {
                                expiracion = value;
                              });
                            },
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
                        child: const Text(
                          'Confirmar reservación',
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

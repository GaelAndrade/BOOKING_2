import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/reservacion_controller.dart';
import '../modelo/reservacion.dart';
import '../theme/app_colors.dart';
import '../utils/payment_validator.dart';
import '../widgets/app_background.dart';

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
  int huespedes = 1;

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

  int get total => numeroNoches * widget.precioPorNoche;

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
      huespedes = widget.reservacion!.huespedes;
    }
  }

  @override
  void dispose() {
    _expiracionController.dispose();
    super.dispose();
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

  void _onExpiracionChanged(String value) {
    final formatted = PaymentValidator.formatExpiration(value);
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

    if (nombreTitular.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del titular.')),
      );
      return;
    }

    if (!PaymentValidator.isCardNumberValid(numeroTarjeta)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El número de tarjeta debe tener 16 dígitos.'),
        ),
      );
      return;
    }

    if (!PaymentValidator.isExpirationValid(expiracion)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una fecha de expiración válida en MM/AA.'),
        ),
      );
      return;
    }

    if (!PaymentValidator.isCvvValid(cvv)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El CVV debe tener 3 dígitos.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await ReservacionController.instance.confirmarReservacion(
      nombreHotel: widget.nombreHotel,
      nombreHabitacion: widget.nombreHabitacion,
      fechaEntrada: fechaEntrada!,
      fechaSalida: fechaSalida!,
      huespedes: huespedes,
      total: total.toDouble(),
      isEditing: isEditing,
      reservacionExistente: widget.reservacion,
    );

    if (!mounted) return;

    messenger.showSnackBar(SnackBar(content: Text(result.mensaje)));

    if (!result.exito) {
      return;
    }

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
              _Header(isEditing: isEditing),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Resumen de estancia',
                icon: Icons.hotel_outlined,
                child: Column(
                  children: [
                    _SummaryLine(
                      label: 'Hotel',
                      value: widget.nombreHotel,
                      icon: Icons.apartment,
                    ),
                    const SizedBox(height: 12),
                    _SummaryLine(
                      label: 'Habitación',
                      value: widget.nombreHabitacion,
                      icon: Icons.bed_outlined,
                    ),
                    const SizedBox(height: 12),
                    _SummaryLine(
                      label: 'Precio por noche',
                      value: '\$${widget.precioPorNoche} MXN',
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Fechas',
                icon: Icons.calendar_month_outlined,
                child: Column(
                  children: [
                    _DateButton(
                      title: 'Entrada',
                      value: _formatearFecha(fechaEntrada),
                      onPressed: _seleccionarFechaEntrada,
                    ),
                    const SizedBox(height: 12),
                    _DateButton(
                      title: 'Salida',
                      value: _formatearFecha(fechaSalida),
                      onPressed: _seleccionarFechaSalida,
                    ),
                    const SizedBox(height: 12),
                    _GuestSelector(
                      value: huespedes,
                      onChanged: (value) {
                        setState(() {
                          huespedes = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _TotalPanel(noches: numeroNoches, total: total),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Método de pago',
                icon: Icons.credit_card,
                child: Column(
                  children: [
                    _PaymentField(
                      label: 'Nombre del titular',
                      icon: Icons.person_outline,
                      onChanged: (value) {
                        setState(() {
                          nombreTitular = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _PaymentField(
                      label: 'Número de tarjeta',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          child: _PaymentField(
                            label: 'MM/AA',
                            icon: Icons.event_outlined,
                            controller: _expiracionController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9/]'),
                              ),
                            ],
                            onChanged: _onExpiracionChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PaymentField(
                            label: 'CVV',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                cvv = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _confirmarReservacion,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    isEditing ? 'Actualizar reservación' : 'Confirmar reserva',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isEditing;

  const _Header({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            isEditing ? 'Editar reserva' : 'Nueva reserva',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Icon(icon, color: AppColors.darkBlue, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1D2530),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkBlue, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1D2530),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onPressed;

  const _DateButton({
    required this.title,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.42)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.darkBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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

class _GuestSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _GuestSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppColors.darkBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Huéspedes',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$value ${value == 1 ? 'huésped' : 'huéspedes'}',
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.darkBlue,
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF1D2530),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: value < 6 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.darkBlue,
          ),
        ],
      ),
    );
  }
}

class _TotalPanel extends StatelessWidget {
  final int noches;
  final int total;

  const _TotalPanel({required this.noches, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TotalMetric(
              label: 'Noches',
              value: '$noches',
              icon: Icons.nights_stay_outlined,
            ),
          ),
          Container(width: 1, height: 42, color: Colors.black12),
          Expanded(
            child: _TotalMetric(
              label: 'Total',
              value: '\$$total MXN',
              icon: Icons.payments_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TotalMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.darkBlue, size: 21),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
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
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentField extends StatelessWidget {
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _PaymentField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.35)),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color(0xFF1D2530),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        hintStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: AppColors.darkBlue),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.lightBlue, width: 2),
        ),
      ),
    );
  }
}

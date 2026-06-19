import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';
import '../modelo/reservacion.dart';
import '../repositories/habitacion_repository.dart';
import '../repositories/hotel_repository.dart';
import '../repositories/reservacion_repository.dart';
import 'user_controller.dart';

class ReservacionResult {
  final bool exito;
  final String mensaje;

  const ReservacionResult._({required this.exito, required this.mensaje});

  factory ReservacionResult.ok(String mensaje) {
    return ReservacionResult._(exito: true, mensaje: mensaje);
  }

  factory ReservacionResult.error(String mensaje) {
    return ReservacionResult._(exito: false, mensaje: mensaje);
  }
}

class ReservacionController {
  ReservacionController._();
  static final ReservacionController instance = ReservacionController._();

  Future<int?> ensureCurrentUserId() {
    return UserController.instance.ensureCurrentUserId();
  }

  Future<List<Reservacion>> getReservacionesUsuarioActual() async {
    final usuarioId = await ensureCurrentUserId();
    if (usuarioId == null) return [];
    return ReservacionRepository.instance.getReservacionesPorUsuario(usuarioId);
  }

  Future<Map<int, String>> getNombresHotelesPorId() async {
    final hoteles = await HotelRepository.instance.getAllHotels();
    return {
      for (final hotel in hoteles)
        if (hotel.id != null) hotel.id!: hotel.nombre,
    };
  }

  Future<Hotel?> getHotelPorNombre(String nombre) {
    return HotelRepository.instance.getHotelPorNombre(nombre);
  }

  Future<Hotel?> getHotelPorId(int id) {
    return HotelRepository.instance.getHotelPorId(id);
  }

  Future<Habitacion?> getHabitacionPorHotelYNombre(int hotelId, String nombre) {
    return HabitacionRepository.instance.getHabitacionPorHotelYNombre(
      hotelId,
      nombre,
    );
  }

  Future<ReservacionResult> confirmarReservacion({
    required String nombreHotel,
    required String nombreHabitacion,
    required DateTime fechaEntrada,
    required DateTime fechaSalida,
    required int huespedes,
    required double total,
    required bool isEditing,
    Reservacion? reservacionExistente,
  }) async {
    final hotel = await getHotelPorNombre(nombreHotel);
    if (hotel == null || hotel.id == null) {
      return ReservacionResult.error(
        'No se encontró el hotel en la base de datos.',
      );
    }

    if (!fechaSalida.isAfter(fechaEntrada)) {
      return ReservacionResult.error(
        'La fecha de salida debe ser posterior a la fecha de entrada.',
      );
    }

    if (huespedes < 1) {
      return ReservacionResult.error('Selecciona al menos un huésped.');
    }

    final existeEmpalme = await ReservacionRepository.instance
        .existeReservacionEmpalmada(
          hotelId: hotel.id!,
          habitacionNombre: nombreHabitacion,
          fechaEntrada: fechaEntrada.millisecondsSinceEpoch,
          fechaSalida: fechaSalida.millisecondsSinceEpoch,
          excluirReservacionId: reservacionExistente?.id,
        );
    if (existeEmpalme) {
      return ReservacionResult.error(
        'La habitación no está disponible en esas fechas.',
      );
    }

    final usuarioId = await ensureCurrentUserId();
    if (usuarioId == null) {
      return ReservacionResult.error('Inicia sesión antes de reservar.');
    }

    final reservacion = Reservacion(
      id: reservacionExistente?.id,
      usuarioId: usuarioId,
      hotelId: hotel.id!,
      habitacionNombre: nombreHabitacion,
      fechaEntrada: fechaEntrada.millisecondsSinceEpoch,
      fechaSalida: fechaSalida.millisecondsSinceEpoch,
      huespedes: huespedes,
      total: total,
      estado: reservacionExistente?.estado ?? 'confirmada',
      createdAt:
          reservacionExistente?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
    );

    await guardarReservacion(reservacion);
    return ReservacionResult.ok(
      isEditing
          ? 'Reservación actualizada.'
          : 'Reservación guardada en la base de datos.',
    );
  }

  Future<int> guardarReservacion(Reservacion reservacion) {
    return ReservacionRepository.instance.guardarReservacion(reservacion);
  }

  Future<bool> eliminarReservacion(int id) async {
    return ReservacionRepository.instance.eliminarReservacion(id);
  }
}

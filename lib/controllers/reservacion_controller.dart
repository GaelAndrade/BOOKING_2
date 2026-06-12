import '../data/app_database.dart';
import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';
import '../modelo/reservacion.dart';
import 'user_controller.dart';

class ReservacionController {
  ReservacionController._();
  static final ReservacionController instance = ReservacionController._();

  Future<int?> ensureCurrentUserId() {
    return UserController.instance.ensureCurrentUserId();
  }

  Future<List<Reservacion>> getReservacionesUsuarioActual() async {
    final usuarioId = await ensureCurrentUserId();
    if (usuarioId == null) return [];
    return AppDatabase.instance.getReservacionesPorUsuario(usuarioId);
  }

  Future<Map<int, String>> getNombresHotelesPorId() async {
    final hoteles = await AppDatabase.instance.getAllHotels();
    return {
      for (final hotel in hoteles)
        if (hotel.id != null) hotel.id!: hotel.nombre,
    };
  }

  Future<Hotel?> getHotelPorNombre(String nombre) {
    return AppDatabase.instance.getHotelPorNombre(nombre);
  }

  Future<Hotel?> getHotelPorId(int id) {
    return AppDatabase.instance.getHotelPorId(id);
  }

  Future<Habitacion?> getHabitacionPorHotelYNombre(int hotelId, String nombre) {
    return AppDatabase.instance.getHabitacionPorHotelYNombre(hotelId, nombre);
  }

  Future<int> guardarReservacion(Reservacion reservacion) {
    if (reservacion.id == null) {
      return AppDatabase.instance.insertReservacion(reservacion);
    }
    return AppDatabase.instance.updateReservacion(reservacion);
  }

  Future<bool> eliminarReservacion(int id) async {
    final filasEliminadas = await AppDatabase.instance.deleteReservacion(id);
    return filasEliminadas > 0;
  }
}

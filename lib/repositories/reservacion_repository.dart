import '../data/app_database.dart';
import '../modelo/reservacion.dart';

class ReservacionRepository {
  ReservacionRepository._();
  static final ReservacionRepository instance = ReservacionRepository._();

  Future<List<Reservacion>> getReservacionesPorUsuario(int usuarioId) {
    return AppDatabase.instance.getReservacionesPorUsuario(usuarioId);
  }

  Future<bool> existeReservacionEmpalmada({
    required int hotelId,
    required String habitacionNombre,
    required int fechaEntrada,
    required int fechaSalida,
    int? excluirReservacionId,
  }) {
    return AppDatabase.instance.existeReservacionEmpalmada(
      hotelId: hotelId,
      habitacionNombre: habitacionNombre,
      fechaEntrada: fechaEntrada,
      fechaSalida: fechaSalida,
      excluirReservacionId: excluirReservacionId,
    );
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

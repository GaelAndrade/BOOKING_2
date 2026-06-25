import '../data/app_database.dart';
import '../data/api_client.dart';
import '../modelo/reservacion.dart';

class ReservacionRepository {
  ReservacionRepository._();
  static final ReservacionRepository instance = ReservacionRepository._();

  Future<List<Reservacion>> getReservacionesPorUsuario(int usuarioId) async {
    try {
      final response =
          await ApiClient.instance.get('/api/reservaciones/usuario/$usuarioId')
              as List;
      final reservaciones = response
          .map(
            (row) => Reservacion.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
      for (final reservacion in reservaciones) {
        await _guardarLocal(reservacion);
      }
      return reservaciones;
    } catch (_) {
      return AppDatabase.instance.getReservacionesPorUsuario(usuarioId);
    }
  }

  Future<bool> existeReservacionEmpalmada({
    required int hotelId,
    required String habitacionNombre,
    required int fechaEntrada,
    required int fechaSalida,
    int? excluirReservacionId,
  }) async {
    try {
      final response =
          await ApiClient.instance.get('/api/reservaciones') as List;
      final reservaciones = response
          .map(
            (row) => Reservacion.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
      return reservaciones.any(
        (reservacion) =>
            reservacion.id != excluirReservacionId &&
            reservacion.hotelId == hotelId &&
            reservacion.habitacionNombre.toLowerCase() ==
                habitacionNombre.toLowerCase() &&
            reservacion.fechaEntrada < fechaSalida &&
            reservacion.fechaSalida > fechaEntrada,
      );
    } catch (_) {
      return AppDatabase.instance.existeReservacionEmpalmada(
        hotelId: hotelId,
        habitacionNombre: habitacionNombre,
        fechaEntrada: fechaEntrada,
        fechaSalida: fechaSalida,
        excluirReservacionId: excluirReservacionId,
      );
    }
  }

  Future<int> guardarReservacion(Reservacion reservacion) async {
    try {
      if (reservacion.id == null) {
        final response = await ApiClient.instance.post(
          '/api/reservaciones',
          reservacion.toMap(),
        );
        final created = Reservacion.fromMap(
          Map<String, dynamic>.from(response as Map),
        );
        await _guardarLocal(created);
        return created.id ?? 0;
      }

      final response = await ApiClient.instance.put(
        '/api/reservaciones/${reservacion.id}',
        reservacion.toMap(),
      );
      final updated = Reservacion.fromMap(
        Map<String, dynamic>.from(response as Map),
      );
      await _guardarLocal(updated);
      return updated.id ?? reservacion.id!;
    } catch (error) {
      if (error is ApiException) rethrow;
      if (reservacion.id == null) {
        return AppDatabase.instance.insertReservacion(reservacion);
      }
      return AppDatabase.instance.updateReservacion(reservacion);
    }
  }

  Future<bool> eliminarReservacion(int id) async {
    try {
      await ApiClient.instance.delete('/api/reservaciones/$id');
      await AppDatabase.instance.deleteReservacion(id);
      return true;
    } catch (error) {
      if (error is ApiException) rethrow;
      final filasEliminadas = await AppDatabase.instance.deleteReservacion(id);
      return filasEliminadas > 0;
    }
  }

  Future<int> _guardarLocal(Reservacion reservacion) async {
    if (reservacion.id == null) {
      return AppDatabase.instance.insertReservacion(reservacion);
    }

    final filasActualizadas = await AppDatabase.instance.updateReservacion(
      reservacion,
    );
    if (filasActualizadas > 0) return filasActualizadas;

    return AppDatabase.instance.insertReservacion(reservacion);
  }
}

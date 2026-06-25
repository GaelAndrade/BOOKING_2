import '../data/app_database.dart';
import '../data/api_client.dart';
import '../modelo/habitacion.dart';

class HabitacionRepository {
  HabitacionRepository._();
  static final HabitacionRepository instance = HabitacionRepository._();

  Future<List<Habitacion>> getHabitacionesPorHotel(int hotelId) async {
    try {
      final response =
          await ApiClient.instance.get('/api/hoteles/$hotelId/habitaciones')
              as List;
      return response
          .map(
            (row) => Habitacion.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    } catch (_) {
      return AppDatabase.instance.getHabitacionesPorHotel(hotelId);
    }
  }

  Future<Habitacion?> getHabitacionPorHotelYNombre(
    int hotelId,
    String nombre,
  ) async {
    try {
      final habitaciones = await getHabitacionesPorHotel(hotelId);
      for (final habitacion in habitaciones) {
        if (habitacion.nombre.toLowerCase() == nombre.toLowerCase()) {
          return habitacion;
        }
      }
      return null;
    } catch (_) {
      return AppDatabase.instance.getHabitacionPorHotelYNombre(hotelId, nombre);
    }
  }
}

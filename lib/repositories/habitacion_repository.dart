import '../data/app_database.dart';
import '../modelo/habitacion.dart';

class HabitacionRepository {
  HabitacionRepository._();
  static final HabitacionRepository instance = HabitacionRepository._();

  Future<List<Habitacion>> getHabitacionesPorHotel(int hotelId) {
    return AppDatabase.instance.getHabitacionesPorHotel(hotelId);
  }

  Future<Habitacion?> getHabitacionPorHotelYNombre(int hotelId, String nombre) {
    return AppDatabase.instance.getHabitacionPorHotelYNombre(hotelId, nombre);
  }
}

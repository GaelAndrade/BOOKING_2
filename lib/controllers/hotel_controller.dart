import '../data/app_database.dart';
import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';

class HotelController {
  HotelController._();
  static final HotelController instance = HotelController._();

  Future<List<Hotel>> getHotels() async {
    return AppDatabase.instance.getAllHotels();
  }

  Future<Hotel?> getHotelById(int id) async {
    return AppDatabase.instance.getHotelPorId(id);
  }

  Future<Hotel?> getHotelByName(String nombre) async {
    return AppDatabase.instance.getHotelPorNombre(nombre);
  }

  Future<List<Habitacion>> getRoomsForHotel(int hotelId) async {
    return AppDatabase.instance.getHabitacionesPorHotel(hotelId);
  }

  Future<Habitacion?> getRoomByName(int hotelId, String nombre) async {
    return AppDatabase.instance.getHabitacionPorHotelYNombre(hotelId, nombre);
  }
}

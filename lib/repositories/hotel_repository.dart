import '../data/app_database.dart';
import '../modelo/hotel.dart';

class HotelRepository {
  HotelRepository._();
  static final HotelRepository instance = HotelRepository._();

  Future<List<Hotel>> getAllHotels() {
    return AppDatabase.instance.getAllHotels();
  }

  Future<Hotel?> getHotelPorId(int id) {
    return AppDatabase.instance.getHotelPorId(id);
  }

  Future<Hotel?> getHotelPorNombre(String nombre) {
    return AppDatabase.instance.getHotelPorNombre(nombre);
  }
}

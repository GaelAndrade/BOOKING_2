import '../data/app_database.dart';
import '../data/api_client.dart';
import '../modelo/hotel.dart';

class HotelRepository {
  HotelRepository._();
  static final HotelRepository instance = HotelRepository._();

  Future<List<Hotel>> getAllHotels() {
    return _fromApiList(
      '/api/hoteles',
      fallback: AppDatabase.instance.getAllHotels,
    );
  }

  Future<Hotel?> getHotelPorId(int id) async {
    try {
      final response = await ApiClient.instance.get('/api/hoteles/$id');
      return Hotel.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (_) {
      return AppDatabase.instance.getHotelPorId(id);
    }
  }

  Future<Hotel?> getHotelPorNombre(String nombre) async {
    try {
      final hoteles = await getAllHotels();
      for (final hotel in hoteles) {
        if (hotel.nombre.toLowerCase() == nombre.toLowerCase()) {
          return hotel;
        }
      }
      return null;
    } catch (_) {
      return AppDatabase.instance.getHotelPorNombre(nombre);
    }
  }

  Future<List<Hotel>> _fromApiList(
    String path, {
    required Future<List<Hotel>> Function() fallback,
  }) async {
    try {
      final response = await ApiClient.instance.get(path) as List;
      return response
          .map((row) => Hotel.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (_) {
      return fallback();
    }
  }
}

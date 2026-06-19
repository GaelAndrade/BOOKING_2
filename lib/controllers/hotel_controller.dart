import '../modelo/habitacion.dart';
import '../modelo/hotel.dart';
import '../repositories/habitacion_repository.dart';
import '../repositories/hotel_repository.dart';

class HotelController {
  HotelController._();
  static final HotelController instance = HotelController._();

  Future<List<Hotel>> getHotels() async {
    return HotelRepository.instance.getAllHotels();
  }

  Future<Hotel?> getHotelById(int id) async {
    return HotelRepository.instance.getHotelPorId(id);
  }

  Future<Hotel?> getHotelByName(String nombre) async {
    return HotelRepository.instance.getHotelPorNombre(nombre);
  }

  Future<List<Habitacion>> getRoomsForHotel(int hotelId) async {
    return HabitacionRepository.instance.getHabitacionesPorHotel(hotelId);
  }

  Future<Habitacion?> getRoomByName(int hotelId, String nombre) async {
    return HabitacionRepository.instance.getHabitacionPorHotelYNombre(
      hotelId,
      nombre,
    );
  }
}

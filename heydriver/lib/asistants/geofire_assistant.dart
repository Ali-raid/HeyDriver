import 'package:heydriver/models/active_nearby_available_drivers.dart';

class GeoFireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList =
      [];
  //offline olan sürücüleri listeden siler dolayısıyla ekrandan da ama kullanmıyoruz bunu da
  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverId);
    activeNearbyAvailableDriversList.removeAt(indexNumber);
  }

  //müsait sürü şoförlerinin listesini günceller kullanmıyoruz bunu
  static void updateActiveNearbyAvailableDriverLocation(
      ActiveNearbyAvailableDrivers driverWhoMove) {
    int indexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activeNearbyAvailableDriversList[indexNumber].locationLatitude =
        driverWhoMove.locationLatitude;
    activeNearbyAvailableDriversList[indexNumber].locationLongitude =
        driverWhoMove.locationLongitude;
  }
}

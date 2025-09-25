import 'package:geocoding/geocoding.dart';

class AddressService {
  Map<String, String> addressCache = {};
  Map<String, String> newAddressCache = {};

  Future<String> getAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
    if (addressCache.containsKey(key)) {
      return addressCache[key]!;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress = '${placemarks[0].locality}';
        addressCache[key] = newAddress;
        return newAddress;
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }

  Future<String> getNewBookingAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';
    if (newAddressCache.containsKey(key)) {
      return newAddressCache[key]!;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress = '${placemarks[0].locality}';
        newAddressCache[key] = newAddress;
        return newAddress;
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }
}

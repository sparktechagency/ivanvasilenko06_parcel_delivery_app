import 'package:geocoding/geocoding.dart';

class AddressService {
  // Caching maps
  Map<String, String> addressCache = {};
  Map<String, String> newAddressCache = {};

  Future<String> getAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';

    // Check if the address is already cached
    if (addressCache.containsKey(key)) {
      return addressCache[key]!;
    }

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0]
            .country}';
        addressCache[key] = newAddress; // Cache the address
        return newAddress;
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }

  // Fetch new booking address (same as above, just for another cache)
  Future<String> getNewBookingAddress(double latitude, double longitude) async {
    final String key = '$latitude,$longitude';

    // Check if the new booking address is already cached
    if (newAddressCache.containsKey(key)) {
      return newAddressCache[key]!;
    }

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0]
            .country}';
        newAddressCache[key] = newAddress; // Cache the address
        return newAddress;
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error fetching address';
    }
  }
}

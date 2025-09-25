import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppLocationFinder {
  // Function to convert latitude and longitude to address
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Get the list of places (addresses) from geocoding based on latitude and longitude
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';
        return address;
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied');
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}

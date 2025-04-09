// location_repository.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parcel_delivery_app/constants/api_key.dart';

class LocationRepository {
  LatLng? startingLocationCoordinates;
  LatLng? endingLocationCoordinates;
  Set<Marker> markers = <Marker>{};
  Polyline? polyline;
  GoogleMapController? mapController;

  // Function to fetch autocomplete predictions from Google Places API
  // Function to fetch the details of the selected place using the place_id
  Future<void> fetchPlaceDetails(String placeId, String locationType) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': apikey, // API key
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];

        if (locationType == 'starting') {
          startingLocationCoordinates =
              LatLng(location['lat'], location['lng']);
          markers.add(Marker(
            markerId: MarkerId('starting-location'),
            position: startingLocationCoordinates!,
            infoWindow: InfoWindow(
              title: 'Starting Location',
              snippet: 'This is your starting location',
            ),
          ));
        } else if (locationType == 'ending') {
          endingLocationCoordinates = LatLng(location['lat'], location['lng']);
          markers.add(Marker(
            markerId: MarkerId('ending-location'),
            position: endingLocationCoordinates!,
            infoWindow: InfoWindow(
              title: 'Ending Location',
              snippet: 'This is your ending location',
            ),
          ));
        }

        // Once both locations are selected, fetch the directions
        if (startingLocationCoordinates != null &&
            endingLocationCoordinates != null) {
          await fetchDirections();
        }

        // Move camera to the selected location
        mapController?.animateCamera(CameraUpdate.newLatLng(
          locationType == 'starting'
              ? startingLocationCoordinates!
              : endingLocationCoordinates!,
        ));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Fetch directions using the Google Directions API
  Future<void> fetchDirections() async {
    if (startingLocationCoordinates == null ||
        endingLocationCoordinates == null) {
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startingLocationCoordinates!.latitude},${startingLocationCoordinates!.longitude}&destination=${endingLocationCoordinates!.latitude},${endingLocationCoordinates!.longitude}&key=$apikey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> polylineCoordinates =
          _decodePolyline(data['routes'][0]['overview_polyline']['points']);
      polyline = Polyline(
        polylineId: PolylineId('route'),
        points: polylineCoordinates,
        color: Colors.black,
        width: 5,
      );
    } else {
      debugPrint('Error fetching directions: ${response.statusCode}');
    }
  }

  // Decode polyline encoded string into LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      // Decode longitude
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      polylineCoordinates.add(LatLng(
        (lat / 1E5).toDouble(),
        (lng / 1E5).toDouble(),
      ));
    }
    return polylineCoordinates;
  }
}

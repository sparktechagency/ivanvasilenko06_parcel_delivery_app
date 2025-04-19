// location_repository.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:parcel_delivery_app/constants/api_key.dart';

class LocationRepository {
  // State variables
  bool _isLoading = false;
  List<dynamic> _placePredictions = [];
  LatLng? _startingLocationCoordinates;
  LatLng? _endingLocationCoordinates;
  LatLng? _currentLocationCoordinates;
  final Set<Marker> _markers = <Marker>{};
  Polyline? _polyline;

  // Getters for state
  bool get isLoading => _isLoading;

  List<dynamic> get placePredictions => _placePredictions;

  LatLng? get startingLocationCoordinates => _startingLocationCoordinates;

  LatLng? get endingLocationCoordinates => _endingLocationCoordinates;

  LatLng? get currentLocationCoordinates => _currentLocationCoordinates;

  Set<Marker> get markers => _markers;

  Polyline? get polyline => _polyline;

  // Clear place predictions
  void clearPlacePredictions() {
    _placePredictions = [];
  }

  // Fetch current location
  Future<LatLng?> getCurrentLocation() async {
    Location location = Location();

    // Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        debugPrint("Location services are disabled");
        return null;
      }
    }

    // Check and request location permission
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint("Location permission not granted");
        return null;
      }
    }

    // Get the current location data
    try {
      LocationData locationData = await location.getLocation();
      _currentLocationCoordinates =
          LatLng(locationData.latitude!, locationData.longitude!);
      return _currentLocationCoordinates;
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  // Place auto-complete suggestions
  Future<List<dynamic>> placeAutoComplete(String query) async {
    if (query.isEmpty) {
      _placePredictions = [];
      return _placePredictions;
    }

    _isLoading = true;

    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _placePredictions = data['predictions'];
      } else {
        _placePredictions = [];
      }
    } catch (e) {
      _placePredictions = [];
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
    }

    return _placePredictions;
  }

  // Handle location selection
  void onLocationSelected(String type, String description) {
    clearPlacePredictions();
  }

  // Fetch place details based on placeId
  Future<LatLng?> fetchPlaceDetails(String placeId, String locationType) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];

        LatLng locationCoordinates = LatLng(location['lat'], location['lng']);

        if (locationType == 'starting') {
          _startingLocationCoordinates = locationCoordinates;
          _markers.removeWhere(
              (marker) => marker.markerId.value == 'starting-location');
          _markers.add(
            Marker(
              markerId: const MarkerId('starting-location'),
              position: _startingLocationCoordinates!,
              infoWindow: const InfoWindow(
                title: 'Starting Location',
                snippet: 'This is your starting location',
              ),
            ),
          );
        } else {
          _endingLocationCoordinates = locationCoordinates;
          _markers.removeWhere(
              (marker) => marker.markerId.value == 'ending-location');
          _markers.add(
            Marker(
              markerId: const MarkerId('ending-location'),
              position: _endingLocationCoordinates!,
              infoWindow: const InfoWindow(
                title: 'Ending Location',
                snippet: 'This is your ending location',
              ),
            ),
          );
        }

        // If both locations are set, fetch directions
        if (_startingLocationCoordinates != null &&
            _endingLocationCoordinates != null) {
          await fetchDirections();
        }

        return locationCoordinates;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  // Fetch directions between starting and ending locations
  Future<Polyline?> fetchDirections() async {
    if (_startingLocationCoordinates == null ||
        _endingLocationCoordinates == null) {
      return null;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}&key=$apikey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> polylineCoordinates =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);

        _polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.black,
          width: 5,
        );

        return _polyline;
      } else {
        debugPrint('Error fetching directions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  // Decode the polyline points
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

      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);

      polylineCoordinates.add(
        LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()),
      );
    }
    return polylineCoordinates;
  }
}

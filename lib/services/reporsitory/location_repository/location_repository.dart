import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:parcel_delivery_app/constants/api_key.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';

class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();

  factory LocationRepository() {
    return _instance;
  }

  LocationRepository._internal();

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

  // Setter for current location coordinates
  set currentLocationCoordinates(LatLng? coordinates) {
    _currentLocationCoordinates = coordinates;
    if (coordinates != null) {
      //addCurrentLocationMarker();
    }
  }

  // Method to set current location coordinates
  void setCurrentLocationCoordinates(LatLng coordinates) {
    _currentLocationCoordinates = coordinates;
    // addCurrentLocationMarker();
  }

  void clearPlacePredictions() {
    _placePredictions = [];
  }

  // Fetch current location
  Future<LatLng?> getCurrentLocation() async {
    Location location = Location();

    try {
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
      LocationData locationData = await location.getLocation();

      // Only proceed if we have valid coordinates
      if (locationData.latitude != null && locationData.longitude != null) {
        _currentLocationCoordinates =
            LatLng(locationData.latitude!, locationData.longitude!);
        // addCurrentLocationMarker();
        return _currentLocationCoordinates;
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }

    return null;
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.administrativeArea}";
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
    return "Your Current Location";
  }

  // Place auto-complete suggestions with debouncing
  Future<List<dynamic>> placeAutoComplete(String query) async {
    if (query.isEmpty) {
      _placePredictions = [];
      return _placePredictions;
    }

    _isLoading = true;

    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': apikey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          _placePredictions = data['predictions'];
        } else {
          debugPrint('API Error: ${data['status']}');
          _placePredictions = [];
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        _placePredictions = [];
      }
    } catch (e) {
      debugPrint('Error in place autocomplete: $e');
      _placePredictions = [];
    } finally {
      _isLoading = false;
    }

    return _placePredictions;
  }

  // Fetch place details based on placeId
  Future<LatLng?> fetchPlaceDetails(String placeId, String locationType) async {
    if (placeId.isEmpty) {
      debugPrint('Empty placeId provided');
      return null;
    }

    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'geometry',
          'key': apikey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['result'] != null) {
          final location = data['result']['geometry']['location'];
          LatLng locationCoordinates = LatLng(location['lat'], location['lng']);

          if (locationType == 'starting') {
            _startingLocationCoordinates = locationCoordinates;
            _updateMarker('starting-location', _startingLocationCoordinates!,
                'Pickup Location');
          } else {
            _endingLocationCoordinates = locationCoordinates;
            _updateMarker(
                'ending-location', _endingLocationCoordinates!, 'Destination');
          }

          // If both locations are set, fetch directions
          if (_startingLocationCoordinates != null &&
              _endingLocationCoordinates != null) {
            await fetchDirections();
          }

          return locationCoordinates;
        } else {
          debugPrint('API Error: ${data['status']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }

    return null;
  }

  // Helper to update a marker
  void _updateMarker(String markerId, LatLng position, String title) {
    _markers.removeWhere((marker) => marker.markerId.value == markerId);
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(
          title: title,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  // Fetch directions between starting and ending locations
  Future<Polyline?> fetchDirections() async {
    if (_startingLocationCoordinates == null ||
        _endingLocationCoordinates == null) {
      return null;
    }

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_startingLocationCoordinates!.latitude},${_startingLocationCoordinates!.longitude}&destination=${_endingLocationCoordinates!.latitude},${_endingLocationCoordinates!.longitude}&key=$apikey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final List<LatLng> polylineCoordinates =
              _decodePolyline(data['routes'][0]['overview_polyline']['points']);

          _polyline = Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: AppColors.black,
            width: 5,
          );

          return _polyline;
        } else {
          debugPrint('API Error: ${data['status']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
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

  // //Add a marker for current location
  // void addCurrentLocationMarker() {
  //   if (_currentLocationCoordinates != null) {
  //     _markers
  //         .removeWhere((marker) => marker.markerId.value == 'current-location');
  //     _markers.add(
  //       Marker(
  //         markerId: const MarkerId('current-location'),
  //         position: _currentLocationCoordinates!,
  //         infoWindow: const InfoWindow(
  //           title: 'Current Location',
  //           snippet: 'You are here',
  //         ),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       ),
  //     );
  //   }
  // }

  // Clear all markers and polylines
  void clearMapData() {
    _markers.clear();
    _polyline = null;
    _startingLocationCoordinates = null;
    _endingLocationCoordinates = null;
  }
}

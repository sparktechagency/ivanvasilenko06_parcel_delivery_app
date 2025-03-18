import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _currentLocationController =
  TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  LatLng? _currentLocation;
  LatLng? _destination;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final PolylinePoints _polylinePoints = PolylinePoints();
  final String _apiKey =
      "YOAIzaSyAszXC1be8aJ37eHuNcBm_-O1clWkPUwV4"; // Replace with your Google Maps API key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 15),
    );
  }

  // Open place picker
  // Future<void> _openPlacePicker(bool isCurrentLocation) async {
  //   PickResult? result = await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         apiKey: _apiKey,
  //         initialPosition: _currentLocation ?? const LatLng(37.4219999, -122.0840575),
  //         useCurrentLocation: true,
  //       ),
  //     ),
  //   );
  //
  //   if (result != null) {
  //     double lat = result.geometry!.location.lat;
  //     double lng = result.geometry!.location.lng;
  //
  //     setState(() {
  //       if (isCurrentLocation) {
  //         _currentLocation = LatLng(lat, lng);
  //         _currentLocationController.text = result.formattedAddress ?? "";
  //       } else {
  //         _destination = LatLng(lat, lng);
  //         _destinationController.text = result.formattedAddress ?? "";
  //       }
  //     });
  //
  //     // Add marker to the map
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId(isCurrentLocation ? "current" : "destination"),
  //         position: LatLng(lat, lng),
  //         infoWindow: InfoWindow(title: result.formattedAddress),
  //       ),
  //     );
  //
  //     // Move camera to the selected location
  //     _mapController?.animateCamera(
  //       CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
  //     );
  //
  //     // Fetch and draw directions if both locations are set
  //     if (_currentLocation != null && _destination != null) {
  //       _fetchDirections();
  //     }
  //   }
  // }

  // Fetch directions using the Directions API

  Future<void> _fetchDirections() async {
    final response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=$_apiKey"));
    final data = jsonDecode(response.body);

    // Decode polyline points
    List<PointLatLng> points = _polylinePoints
        .decodePolyline(data['routes'][0]['overview_polyline']['points']);

    // Convert points to LatLng list
    List<LatLng> polylineCoordinates =
    points.map((point) => LatLng(point.latitude, point.longitude)).toList();

    // Draw polyline on the map
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map with Directions"),
      ),
      body: Column(
        children: [
          // Current Location Search Box
          TextField(
            controller: _currentLocationController,
            decoration: const InputDecoration(
              hintText: "Enter current location",
              border: OutlineInputBorder(),
            ),

          ),
          const SizedBox(height: 10),
          // Destination Search Box
          TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              hintText: "Enter destination",
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(37.4219999, -122.0840575),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}

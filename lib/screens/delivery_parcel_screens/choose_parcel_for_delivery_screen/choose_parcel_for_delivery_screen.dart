import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/constants/api_key.dart';
import 'package:http/http.dart' as http;
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class ChooseParcelForDeliveryScreen extends StatefulWidget {
  const ChooseParcelForDeliveryScreen({super.key});

  @override
  State<ChooseParcelForDeliveryScreen> createState() =>
      _ChooseParcelForDeliveryScreenState();
}

class _ChooseParcelForDeliveryScreenState
    extends State<ChooseParcelForDeliveryScreen> {
  final DeliveryScreenController _controller =
      Get.find<DeliveryScreenController>();

  Set<Marker> _markers = {};
  Polyline? _polyline;

  @override
  void initState() {
    super.initState();
    _setMarkersAndPolyline();
  }

  // Set markers for current and destination locations
  void _setMarkersAndPolyline() {
    final startingLocation = _controller.startingCoordinates.value;
    final destinationLocation = _controller.endingCoordinates.value;

    if (startingLocation != null && destinationLocation != null) {
      // Add the starting marker
      _markers.add(
        Marker(
          markerId: const MarkerId('starting-location'),
          position: startingLocation,
          infoWindow: const InfoWindow(title: 'Starting Location'),
        ),
      );

      // Add the ending marker
      _markers.add(
        Marker(
          markerId: const MarkerId('destination-location'),
          position: destinationLocation,
          infoWindow: const InfoWindow(title: 'Destination Location'),
        ),
      );

      _fetchDirections(startingLocation, destinationLocation);
    }
  }

  // Fetch directions and create polyline
  Future<void> _fetchDirections(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apikey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final polylineCoordinates =
          _decodePolyline(data['routes'][0]['overview_polyline']['points']);

      setState(() {
        _polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: AppColors.black,
          width: 5,
        );
      });
    } else {
      print("Failed to load directions");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const Icon(Icons.arrow_back, size: 28),
        title: TextWidget(
          text: "Choose Delivery Percel".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        titleSpacing: -7,
      ),
      backgroundColor: AppColors.white,
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _controller.startingCoordinates.value ??
              const LatLng(0.0, 0.0), // Default to (0,0) if no coordinates
          zoom: 12,
        ),
        onMapCreated: (controller) {},
        markers: _markers,
        polylines: _polyline != null ? {_polyline!} : {},
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                Get.toNamed(AppRoutes.parcelForDeliveryScreen);
              },
              label: "Next",
              textColor: Colors.white,
              buttonWidth: 105,
              buttonHeight: 50,
              icon: Icons.arrow_forward,
              iconColor: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

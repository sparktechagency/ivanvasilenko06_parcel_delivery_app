import 'dart:convert'; // for JSON decoding
import 'dart:developer';
import 'dart:math' as math; // for distance calculation

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // for API requests
import 'package:parcel_delivery_app/constants/api_key.dart'; // for API key
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import 'package:parcel_delivery_app/screens/delivery_parcel_screens/parcel_for_delivery_screen/parcel_for_delivery_screen.dart';
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
  final DeliveryScreenController controller =
      Get.find<DeliveryScreenController>();

  BitmapDescriptor _pickupMarker =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  BitmapDescriptor _destinationMarker =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchRoute(); // fetch route for polyline
  }

  // Calculate distance between two coordinates in kilometers using the Haversine formula
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    double lat1Rad = point1.latitude * (math.pi / 180);
    double lat2Rad = point2.latitude * (math.pi / 180);
    double lon1Rad = point1.longitude * (math.pi / 180);
    double lon2Rad = point2.longitude * (math.pi / 180);

    double latDiff = lat2Rad - lat1Rad;
    double lonDiff = lon2Rad - lon1Rad;

    double a = math.sin(latDiff / 2) * math.sin(latDiff / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(lonDiff / 2) *
            math.sin(lonDiff / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Calculate the bounds of the polyline to fit it on screen
  LatLngBounds _getPolylineBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      if (minLat == null || point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (maxLat == null || point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (minLng == null || point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (maxLng == null || point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    // Add some padding to the bounds
    final latPadding = (maxLat! - minLat!) * 0.15;
    final lngPadding = (maxLng! - minLng!) * 0.15;

    return LatLngBounds(
      southwest: LatLng(minLat! - latPadding, minLng! - lngPadding),
      northeast: LatLng(maxLat! + latPadding, maxLng! + lngPadding),
    );
  }

  // Fetch route coordinates from Google Directions API
  Future<void> _fetchRoute() async {
    final Map<String, dynamic>? args = Get.arguments;
    if (args == null ||
        !args.containsKey("pickupLatLng") ||
        !args.containsKey("deliveryLatLng")) {
      log('❌ Missing pickup or delivery coordinates');
      return;
    }

    final LatLng pickupLatLng = args["pickupLatLng"];
    final LatLng deliveryLatLng = args["deliveryLatLng"];

    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${pickupLatLng.latitude},${pickupLatLng.longitude}',
        'destination': '${deliveryLatLng.latitude},${deliveryLatLng.longitude}',
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final String polylinePoints =
              data['routes'][0]['overview_polyline']['points'];
          final List<LatLng> polylineCoordinates =
              _decodePolyline(polylinePoints);

          _routePoints = polylineCoordinates;

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylineCoordinates,
                color: AppColors.black,
                width: 6,
              ),
            );
          });

          // Update camera to show full route if map controller is ready
          if (_mapController != null && _routePoints.isNotEmpty) {
            final bounds = _getPolylineBounds(_routePoints);
            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50),
            );
          }
        } else {
          log('❌ Directions API error: ${data['status']}');
        }
      } else {
        log('❌ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error fetching route: $e');
    }
  }

  // Decode polyline points from encoded string
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const Icon(Icons.arrow_back, size: 28),
        title: TextWidget(
          text: "Choose Delivery Parcel".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        titleSpacing: -7,
      ),
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final parcels = controller.parcels;

        // Get current location if available
        LatLng? currentLocationLatLng;
        if (args != null &&
            args.containsKey("currentLocationLatitude") &&
            args.containsKey("currentLocationLongitude")) {
          final currentLat = double.tryParse(args["currentLocationLatitude"]);
          final currentLng = double.tryParse(args["currentLocationLongitude"]);

          if (currentLat != null && currentLng != null) {
            currentLocationLatLng = LatLng(currentLat, currentLng);
          }
        }

        // Get pickup location if available
        LatLng? pickupLocationLatLng;
        if (args != null &&
            args.containsKey("pickupLatitude") &&
            args.containsKey("pickupLongitude")) {
          final pickupLat = double.tryParse(args["pickupLatitude"]);
          final pickupLng = double.tryParse(args["pickupLongitude"]);

          if (pickupLat != null && pickupLng != null) {
            pickupLocationLatLng = LatLng(pickupLat, pickupLng);
          }
        } else if (args != null && args.containsKey("pickupLatLng")) {
          pickupLocationLatLng = args["pickupLatLng"];
        } else if (parcels.isNotEmpty &&
            parcels.first.pickupLocation?.coordinates != null &&
            parcels.first.pickupLocation!.coordinates!.length == 2) {
          final coords = parcels.first.pickupLocation!.coordinates!;
          pickupLocationLatLng = LatLng(coords[1], coords[0]);
        }

        // Determine initial camera position
        LatLng initialLatLng;

        // If both current location and pickup location are available,
        // check if pickup is within 15km
        if (currentLocationLatLng != null && pickupLocationLatLng != null) {
          double distance =
              _calculateDistance(currentLocationLatLng, pickupLocationLatLng);

          log('📏 Distance between current location and pickup: $distance km');

          // If pickup is within 15km radius, use current location as initial position
          if (distance <= 15) {
            log('✅ Pickup is within 15km radius, using current location as initial position');
            initialLatLng = currentLocationLatLng;
          } else {
            log('🔍 Pickup is outside 15km radius, using pickup location as initial position');
            initialLatLng = pickupLocationLatLng;
          }
        }
        // If only pickup location is available, use it
        else if (pickupLocationLatLng != null) {
          log('📍 Using pickup location as initial position (no current location available)');
          initialLatLng = pickupLocationLatLng;
        }
        // If only current location is available, use it
        else if (currentLocationLatLng != null) {
          log('📱 Using current location as initial position (no pickup location available)');
          initialLatLng = currentLocationLatLng;
        }
        // Fallback
        else {
          log('⚠️ No valid location found, using default position');
          initialLatLng =
              const LatLng(23.8103, 90.4125); // Default to Dhaka, Bangladesh
        }

        final Set<Marker> markers = {};

        // Add pickup and delivery markers if present in arguments
        if (args != null &&
            args.containsKey("pickupLatLng") &&
            args.containsKey("deliveryLatLng")) {
          // Add pickup marker
          markers.add(
            Marker(
              markerId: const MarkerId('pickup-location'),
              position: args["pickupLatLng"],
              icon: _pickupMarker,
              infoWindow: const InfoWindow(title: 'Pickup Location'),
            ),
          );

          // Add delivery marker
          markers.add(
            Marker(
              markerId: const MarkerId('delivery-location'),
              position: args["deliveryLatLng"],
              icon: _destinationMarker,
              infoWindow: const InfoWindow(title: 'Delivery Location'),
            ),
          );
        }

        // We're NOT adding parcel markers here anymore as requested

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLatLng,
            zoom: 12,
          ),
          markers: markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;

            // If we already have route points, fit them on the map
            if (_routePoints.isNotEmpty) {
              final bounds = _getPolylineBounds(_routePoints);
              _mapController!.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50),
              );
            }
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          zoomControlsEnabled: true,
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Get.back(),
              child: const CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                controller.fetchDeliveryParcelsList();
                Get.to(
                  const ParcelForDeliveryScreen(),
                  arguments: {
                    "deliveryType": controller.selectedDeliveryType.value,
                    "pickupLocation": controller.pickupLocation.value,
                    "deliveryLocation":
                        controller.selectedDeliveryLocation.value,
                  },
                );
              },
              label: "Next",
              textColor: AppColors.white,
              buttonWidth: 105,
              buttonHeight: 50,
              icon: Icons.arrow_forward,
              iconColor: AppColors.white,
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

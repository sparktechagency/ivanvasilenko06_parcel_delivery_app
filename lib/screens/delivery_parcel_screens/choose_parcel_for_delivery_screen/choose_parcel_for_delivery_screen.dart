import 'dart:convert'; // 🆕 for JSON decoding
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // 🆕 for API requests
import 'package:intl/intl.dart';
import 'package:parcel_delivery_app/constants/api_key.dart'; // 🆕 for API key
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

  BitmapDescriptor? _customMarker;
  Set<Polyline> _polylines = {}; // 🆕 for polyline

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
    _fetchRoute(); // 🆕 fetch route for polyline
  }

  Future<void> _loadCustomMarkerIcon() async {
    _customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/icons/parcelIcon.png',
    );
    setState(() {});
  }

  // 🆕 Fetch route coordinates from Google Directions API
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

  // 🆕 Decode polyline points from encoded string
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

  void _showParcelDetailsBottomSheet(int index) {
    final parcel = controller.parcels[index];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parcel.title ?? 'Parcel',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Sender: ${parcel.senderId?.fullName ?? 'N/A'}"),
                Text("Type: ${parcel.deliveryType ?? ''}"),
                Text("Phone: ${parcel.phoneNumber ?? ''}"),
                Text("Price: ৳${parcel.price ?? ''}"),
                Text(
                  "From: ${DateFormat.yMd().format(DateTime.parse(parcel.deliveryStartTime!))}",
                ),
                Text(
                  "To: ${DateFormat.yMd().format(DateTime.parse(parcel.deliveryEndTime!))}",
                ),
                const SizedBox(height: 12),
                if (parcel.images != null && parcel.images!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://your.api.base.url${parcel.images!.first}',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  )
                else
                  const Text("No image available"),
              ],
            ),
          ),
        );
      },
    );
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

        LatLng? initialLatLng;

        if (args != null &&
            args.containsKey("pickupLatitude") &&
            args.containsKey("pickupLongitude")) {
          final pickupLat = double.tryParse(args["pickupLatitude"]);
          final pickupLng = double.tryParse(args["pickupLongitude"]);

          if (pickupLat != null && pickupLng != null) {
            initialLatLng = LatLng(pickupLat, pickupLng);
          }
        }

        if (initialLatLng == null &&
            args != null &&
            args.containsKey("currentLocationLatitude") &&
            args.containsKey("currentLocationLongitude")) {
          final currentLat = double.tryParse(args["currentLocationLatitude"]);
          final currentLng = double.tryParse(args["currentLocationLongitude"]);

          if (currentLat != null && currentLng != null) {
            initialLatLng = LatLng(currentLat, currentLng);
          }
        }

        if (initialLatLng == null &&
            parcels.isNotEmpty &&
            parcels.first.pickupLocation?.coordinates != null &&
            parcels.first.pickupLocation!.coordinates!.length == 2) {
          final coords = parcels.first.pickupLocation!.coordinates!;
          initialLatLng = LatLng(coords[1], coords[0]);
        }

        if (initialLatLng == null) {
          throw Exception("No valid initial location found");
        }

        final Set<Marker> markers = {};
        for (int i = 0; i < parcels.length; i++) {
          final parcel = parcels[i];
          final coOrdinate = parcel.pickupLocation?.coordinates;

          if (coOrdinate != null) {
            final lat = double.tryParse(coOrdinate[1].toString());
            final lng = double.tryParse(coOrdinate[0].toString());

            if (lat != null && lng != null) {
              log('✅ Showing parcel ${parcel.title} at ($lat, $lng)');

              markers.add(
                Marker(
                  markerId: MarkerId('pickup-$i'),
                  position: LatLng(lat, lng),
                  icon: _customMarker ?? BitmapDescriptor.defaultMarker,
                  onTap: () => _showParcelDetailsBottomSheet(i),
                ),
              );
            } else {
              log('❌ Invalid coordinate for ${parcel.title}');
            }
          } else {
            log('❌ Missing coordinate for ${parcel.title}');
          }
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLatLng!,
            zoom: 12,
          ),
          markers: markers,
          polylines: _polylines,
          // 🆕 add polylines to map
          onMapCreated: (_) {},
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

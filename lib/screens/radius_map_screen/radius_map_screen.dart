import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/home_screen/controller/earn_money_radius_controller.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';

class RadiusMapScreen extends StatefulWidget {
  const RadiusMapScreen({super.key});

  @override
  _RadiusMapScreenState createState() => _RadiusMapScreenState();
}

class _RadiusMapScreenState extends State<RadiusMapScreen> {
  String address = "Loading...";
  Map<String, String> addressCache = {};
  late GoogleMapController mapController;
  final EarnMoneyRadiusController _radiusController = Get.find();
  bool isLoading = true;
  BitmapDescriptor customMarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _loadParcels();
    _updateCurrentAddress();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _loadCustomMarker() async {
    try {
      final Uint8List markerIconBytes =
          await getBytesFromAsset('assets/images/send.png', 100);

      setState(() {
        customMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
      });
    } catch (e) {
      //! log('Error loading custom marker: $e');
      setState(() {
        customMarkerIcon = BitmapDescriptor.defaultMarker;
      });
    }
  }

  void _updateCurrentAddress() {
    if (_radiusController.currentLocation.value != null) {
      _getAddress(
        _radiusController.currentLocation.value!.latitude,
        _radiusController.currentLocation.value!.longitude,
      );
    }
  }

  Future<void> _getAddress(double latitude, double longitude) async {
    if (latitude == 0 && longitude == 0) return;

    final String key = '$latitude,$longitude';
    if (addressCache.containsKey(key)) {
      setState(() {
        address = addressCache[key]!;
      });
      return;
    }
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String newAddress =
            '${placemarks[0].locality}, ${placemarks[0].country}';
        setState(() {
          address = newAddress;
        });
        addressCache[key] = newAddress;
      } else {
        setState(() {
          address = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Error fetching address';
      });
    }
  }

  Future<void> _loadParcels() async {
    setState(() {
      isLoading = true;
    });
    await _radiusController.fetchParcelsInRadius();
    _updateCurrentAddress();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(() {
            return GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                if (_radiusController.currentLocation.value != null) {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _radiusController.currentLocation.value!,
                        zoom: _getZoomLevel(_radiusController.radius.value),
                      ),
                    ),
                  );
                }
              },
              initialCameraPosition: CameraPosition(
                target: _radiusController.currentLocation.value!,
                zoom: _getZoomLevel(_radiusController.radius.value),
              ),
              markers: _createCustomMarkers(),
              circles: {
                Circle(
                  circleId: const CircleId('radius_circle'),
                  center: _radiusController.currentLocation.value!,
                  radius: _radiusController.radius.value * 1000,
                  // Convert km to meters
                  fillColor: AppColors.black.withAlpha(51),
                  strokeColor: AppColors.black,
                  strokeWidth: 1,
                )
              },
              zoomControlsEnabled: false,
            );
          }),
          // Loading indicator
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),
            ),
          //Controls at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Card(
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 3,
                    child: const CircleAvatar(
                      backgroundColor: AppColors.white,
                      radius: 25,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                ButtonWidget(
                  onPressed: () {
                    Get.toNamed(AppRoutes.radiusAvailableParcel);
                  },
                  label: "viewParcel".tr,
                  textColor: AppColors.white,
                  buttonWidth: 150,
                  buttonHeight: 50,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ],
            ),
          ),
          Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(10),
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            address,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Radius of ${_radiusController.radius.value.toStringAsFixed(2)} km"
                                .tr,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  double _getZoomLevel(double radius) {
    double zoomLevel = 11;
    if (radius <= 1) {
      zoomLevel = 15;
    } else if (radius <= 5) {
      zoomLevel = 13;
    } else if (radius <= 10) {
      zoomLevel = 12;
    } else if (radius <= 20) {
      zoomLevel = 11;
    } else {
      zoomLevel = 10;
    }
    return zoomLevel;
  }

  Set<Marker> _createCustomMarkers() {
    Set<Marker> customMarkers = {};
    // Convert controller markers to custom markers
    for (Marker marker in _radiusController.markers) {
      customMarkers.add(
        Marker(
          markerId: marker.markerId,
          position: marker.position,
          // infoWindow: marker.infoWindow,
          icon: customMarkerIcon,
          onTap: marker.onTap,
        ),
      );
    }
    return customMarkers;
  }
}

// radius_map_screen.dart - modifications
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late GoogleMapController mapController;
  final EarnMoneyRadiusController _radiusController = Get.find();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParcels();
  }

  Future<void> _loadParcels() async {
    setState(() {
      isLoading = true;
    });

    await _radiusController.fetchParcelsInRadius();

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
            final currentLoc = _radiusController.currentLocation.value ??
                const LatLng(23.7596, 90.4211); // Default location

            return GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;

                // Add a circle to indicate the radius
                if (_radiusController.currentLocation.value != null) {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: currentLoc,
                        zoom: _getZoomLevel(_radiusController.radius.value),
                      ),
                    ),
                  );
                }
              },
              initialCameraPosition: CameraPosition(
                target: currentLoc,
                zoom: _getZoomLevel(_radiusController.radius.value),
              ),
              markers: Set.from(_radiusController.markers),
              circles: {
                Circle(
                  circleId: const CircleId('radius_circle'),
                  center: currentLoc,
                  radius: _radiusController.radius.value * 1000,
                  // Convert km to meters
                  fillColor: AppColors.black.withAlpha(51),
                  strokeColor: AppColors.black,
                  strokeWidth: 1,
                )
              },
            );
          }),

          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Controls at the bottom
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
                  label: "viewParcels".tr,
                  textColor: AppColors.white,
                  buttonWidth: 150,
                  buttonHeight: 50,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate appropriate zoom level based on radius
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
}

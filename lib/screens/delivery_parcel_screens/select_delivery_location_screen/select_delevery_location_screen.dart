import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parcel_delivery_app/constants/api_key.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import '../controller/delivery_screens_controller.dart';

class SelectDeliveryLocationScreen extends StatefulWidget {
  const SelectDeliveryLocationScreen({super.key});

  @override
  State<SelectDeliveryLocationScreen> createState() =>
      _SelectDeliveryLocationScreenState();
}

class _SelectDeliveryLocationScreenState
    extends State<SelectDeliveryLocationScreen> {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final DeliveryScreenController _controller =
      Get.find<DeliveryScreenController>();

  List<dynamic> _placePredictions = [];
  bool _isLoading = false;
  String _locationType = '';

  // Fetch autocomplete predictions from Google Places API
  Future<void> placeAutoComplete(String query,
      {required String locationType}) async {
    if (query.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _locationType = locationType;
    });

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
        setState(() {
          _placePredictions = data['predictions'];
        });
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
    } catch (e) {
      setState(() {
        _placePredictions = [];
      });
      debugPrint('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle selection of a location (either current or destination)
  void onLocationSelected(String placeId, String description) async {
    setState(() {
      _placePredictions = [];
    });

    // Set the correct text in the respective text field based on location type
    if (_locationType == 'current') {
      _currentLocationController.text = description;
    } else if (_locationType == 'destination') {
      _destinationController.text = description;
    }

    // Fetch place details based on placeId
    await fetchPlaceDetails(placeId);
  }

  // Fetch details of the selected place using the place_id
  Future<void> fetchPlaceDetails(String placeId) async {
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

        // Update the location coordinates in the controller based on the location type
        if (_locationType == 'current') {
          _controller.setStartingLocation(_currentLocationController.text,
              LatLng(location['lat'], location['lng']));
        } else if (_locationType == 'destination') {
          _controller.setEndingLocation(_destinationController.text,
              LatLng(location['lat'], location['lng']));
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const Icon(Icons.arrow_back, size: 28),
        title: TextWidget(
          text: "enterDeliveryLocation".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        titleSpacing: -7,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 24),
                Column(
                  children: [
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.destinationIcon,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.greyLight2,
                    ),
                    const IconWidget(
                      height: 15,
                      width: 15,
                      icon: AppIconsPath.currentLocationIcon,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 12, right: 24, top: 16, bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Current Location Input
                        TextFormField(
                          controller: _currentLocationController,
                          onChanged: (query) {
                            placeAutoComplete(query, locationType: 'current');
                          },
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "currentLocationText".tr,
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(
                          height: 2,
                          color: AppColors.blackLighter,
                        ),
                        // Destination Input
                        TextFormField(
                          controller: _destinationController,
                          onChanged: (query) {
                            placeAutoComplete(query,
                                locationType: 'destination');
                          },
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "destinationText".tr,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading) const CircularProgressIndicator(),
            // Display autocomplete suggestions
            Expanded(
              child: ListView.builder(
                itemCount: _placePredictions.length,
                itemBuilder: (context, index) {
                  final prediction = _placePredictions[index];
                  return ListTile(
                    title: Text(prediction['description']),
                    onTap: () {
                      // Now, we ensure the correct location is passed based on type
                      onLocationSelected(
                          prediction['place_id'], prediction['description']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                backgroundColor: AppColors.white,
                radius: 25,
                child: Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                _controller.fetchParcels();
                Get.toNamed(AppRoutes.chooseParcelForDeliveryScreen,
                    arguments: {
                      "deliveryType": _controller.selectedDeliveryType.value,
                      "pickupLocation": _controller.pickupLocation.value,
                      "deliveryLocation":
                          _controller.selectedDeliveryLocation.value,
                    });
              },
              label: "next".tr,
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

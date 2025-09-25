import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/api_key.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/constants/app_icons_path.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/services/reporsitory/location_repository/location_repository.dart';
import 'package:parcel_delivery_app/services/location_permission_service.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/icon_widget/icon_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

import '../controller/delivery_screens_controller.dart';

class SelectDeliveryLocationScreen extends StatefulWidget {
  const SelectDeliveryLocationScreen({super.key});

  @override
  State<SelectDeliveryLocationScreen> createState() =>
      _SelectDeliveryLocationScreenState();
}

class _SelectDeliveryLocationScreenState
    extends State<SelectDeliveryLocationScreen> {
  final DeliveryScreenController controller =
      Get.find<DeliveryScreenController>();
  final LocationRepository _locationRepository = LocationRepository();

  // Local controllers for the text fields
  final TextEditingController _pickupLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  List<dynamic> _placePredictions = [];
  bool _isLoading = false;
  String _locationType = '';
  bool _hasCurrentLocation = false;
  String _formattedCurrentAddress = "Current Location";

  // Map controller
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    // Only populate text fields if they have values in the controller
    if (controller.pickupLocation.value.isNotEmpty &&
        controller.pickupLocation.value != "Current Location") {
      _pickupLocationController.text = controller.pickupLocation.value;
    }

    if (controller.selectedDeliveryLocation.value.isNotEmpty) {
      _destinationController.text = controller.selectedDeliveryLocation.value;
    }

    // Add listeners to focus nodes
    _pickupFocusNode.addListener(() {
      if (_pickupFocusNode.hasFocus) {
        setState(() {
          _locationType = 'current';
          if (_pickupLocationController.text.isEmpty && _hasCurrentLocation) {
            _showCurrentLocationAsSuggestion();
          }
        });
      } else {
        if (!_destinationFocusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _placePredictions = [];
              });
            }
          });
        }
      }
    });
    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        setState(() {
          _locationType = 'destination';
        });
      } else {
        if (!_pickupFocusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _placePredictions = [];
              });
            }
          });
        }
      }
    });
    _getCurrentLocation();
  }

  void _showCurrentLocationAsSuggestion() {
    setState(() {
      _placePredictions = [
        {
          'place_id': 'current_location',
          'description': 'Pick your current location',
          'isCurrentLocation': true,
        }
      ];
    });
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _pickupLocationController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // Use the uniform location permission service
    final locationService = LocationPermissionService.instance;
    final position = await locationService.getCurrentPosition(
      requestPermission: true,
    );
    
    if (position != null && mounted) {
      final location = LatLng(position.latitude, position.longitude);
      
      controller.setStartingLocation(
        "", // Empty string instead of "Current Location"
        location,
      );
      controller.currentLocationLatitude.value = position.latitude.toString();
      controller.currentLocationLongitude.value = position.longitude.toString();

      setState(() {
        _hasCurrentLocation = true;
      });

      // Get address from coordinates (optional - for better UX)
      try {
        await _getAddressFromLatLng(location);
      } catch (e) {
        debugPrint('Error getting address: $e');
      }
    }
  }

  // Get address from lat/lng (reverse geocoding)
  Future<void> _getAddressFromLatLng(LatLng location) async {
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/geocode/json',
      {
        'latlng': '${location.latitude},${location.longitude}',
        'key': apikey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            _formattedCurrentAddress = data['results'][0]['formatted_address'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Fetch autocomplete predictions from Google Places API
  Future<void> placeAutoComplete(String query,
      {required String locationType}) async {
    if (query.isEmpty) {
      if (locationType == 'current' && _hasCurrentLocation) {
        _showCurrentLocationAsSuggestion();
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
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
          if (locationType == 'current' && _hasCurrentLocation) {
            // Add current location as first suggestion always
            final predictions = data['predictions'] as List;
            _placePredictions = [
              {
                'place_id': 'current_location',
                'description': 'Pick your current location',
                'isCurrentLocation': true,
              },
              ...predictions
            ];
          } else {
            _placePredictions = data['predictions'];
          }
        });
      } else {
        if (locationType == 'current' && _hasCurrentLocation) {
          _showCurrentLocationAsSuggestion();
        } else {
          setState(() {
            _placePredictions = [];
          });
        }
      }
    } catch (e) {
      if (locationType == 'current' && _hasCurrentLocation) {
        _showCurrentLocationAsSuggestion();
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
      debugPrint('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle selection of a prediction
  void onLocationSelected(String placeId, String description,
      {bool isCurrentLocation = false}) async {
    setState(() {
      _placePredictions = [];
    });

    if (_locationType == 'current') {
      if (isCurrentLocation) {
        // Use the actual current location data
        _pickupLocationController.text = _formattedCurrentAddress;
        controller.pickupLocation.value = _formattedCurrentAddress;

        // No need to fetch place details, use existing location data
        // This uses the lat/lng we already got from _getCurrentLocation()
        if (controller.currentLocationLatitude.value.isNotEmpty &&
            controller.currentLocationLongitude.value.isNotEmpty) {
          controller.pickupLocationLatitude.value =
              controller.currentLocationLatitude.value;
          controller.pickupLocationLongitude.value =
              controller.currentLocationLongitude.value;

          // Also update the starting coordinates
          final lat = double.parse(controller.currentLocationLatitude.value);
          final lng = double.parse(controller.currentLocationLongitude.value);
          controller.startingCoordinates.value = LatLng(lat, lng);
        }
      } else {
        _pickupLocationController.text = description;
        controller.pickupLocation.value = description;
        await fetchPlaceDetails(placeId);
      }
    } else if (_locationType == 'destination') {
      _destinationController.text = description;
      controller.selectedDeliveryLocation.value = description;
      await fetchPlaceDetails(placeId);
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();
  }

  // Fetch lat/lng details from place_id
  Future<void> fetchPlaceDetails(String placeId) async {
    // If the place ID is our custom 'current_location' ID, return early
    if (placeId == 'current_location') {
      return;
    }

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

        if (_locationType == 'current') {
          controller.setStartingLocation(
            controller.pickupLocation.value,
            LatLng(location['lat'], location['lng']),
          );
          controller.pickupLocationLatitude.value = location['lat'].toString();
          controller.pickupLocationLongitude.value = location['lng'].toString();

          // Update map if needed
          if (_mapController != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(location['lat'], location['lng'])),
            );
          }
        } else if (_locationType == 'destination') {
          controller.setEndingLocation(
            controller.selectedDeliveryLocation.value,
            LatLng(location['lat'], location['lng']),
          );

          // Set delivery location coordinates
          controller.deliveryLocationLatitude.value =
              location['lat'].toString();
          controller.deliveryLocationLongitude.value =
              location['lng'].toString();

          // Update map if needed
          if (_mapController != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(location['lat'], location['lng'])),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _fetchParcelsAndProceed() {
    if (controller.pickupLocation.value.isEmpty) {
      // Get.snackbar(
      //   "Error",
      //   "Please select a pickup location",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      return;
    }
    if (controller.selectedDeliveryLocation.value.isEmpty) {
      // Get.snackbar(
      //   "Error",
      //   "Please select a destination",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      return;
    }

    controller.fetchParcels();
    Get.toNamed(AppRoutes.chooseParcelForDeliveryScreen, arguments: {
      "deliveryType": controller.selectedDeliveryType.value,
      "pickupLocation": controller.pickupLocation.value,
      "pickupLatLng": controller.startingCoordinates.value,
      "pickupLat": controller.pickupLocationLatitude.value,
      "pickupLng": controller.pickupLocationLongitude.value,
      "deliveryLocation": controller.selectedDeliveryLocation.value,
      "deliveryLatLng": controller.endingCoordinates.value,
      "deliveryLat": controller.deliveryLocationLatitude.value,
      "deliveryLng": controller.deliveryLocationLongitude.value,

      /// For getting current location
      "currentLocationLatitude": controller.currentLocationLatitude.value,
      "currentLocationLongitude": controller.currentLocationLongitude.value,
    });

    //! log('🆒 DeliveryType: ${controller.selectedDeliveryType.value}');
    //! log('✳️ PickupLocation: ${controller.pickupLocation.value}');
    //! log('☑️ PickupLatLng: ${controller.startingCoordinates.value}');
    //! log('📍 PickupLat: ${controller.pickupLocationLatitude.value}');
    //! log('📍 PickupLng: ${controller.pickupLocationLongitude.value}');
    //! log('🛑 DeliveryLocation: ${controller.selectedDeliveryLocation.value}');
    //! log('🚩 DeliveryLatLng: ${controller.endingCoordinates.value}');
    //! log('🎯 DeliveryLat: ${controller.deliveryLocationLatitude.value}');
    //! log('🎯 DeliveryLng: ${controller.deliveryLocationLongitude.value}');
  }

  // Build predictions list with icons - BIGGER SIZE VERSION
  Widget _buildPredictionsList() {
    if (_placePredictions.isEmpty || _isLoading) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _placePredictions.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.greyLight2,
          ),
          itemBuilder: (context, index) {
            final prediction = _placePredictions[index];
            final bool isCurrentLocation =
                prediction['isCurrentLocation'] == true;
            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: Icon(
                isCurrentLocation ? Icons.my_location : Icons.location_on,
                color: AppColors.greyDarkLight2,
                size: 18,
              ),
              title: Text(
                prediction['description'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isCurrentLocation ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                onLocationSelected(
                  prediction['place_id'],
                  prediction['description'],
                  isCurrentLocation: isCurrentLocation,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Get.back(),
        ),
        title: TextWidget(
          text: "enterDeliveryLocation".tr,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontColor: AppColors.black,
        ),
        titleSpacing: -7,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          // Close keyboard and clear suggestions when tapping outside
          FocusScope.of(context).unfocus();
          setState(() {
            _placePredictions = [];
          });
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Main content column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            left: 12,
                            right: 24,
                            top: 16,
                            bottom: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.black, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Current Location
                              TextFormField(
                                controller: _pickupLocationController,
                                focusNode: _pickupFocusNode,
                                onChanged: (query) {
                                  controller.pickupLocation.value = query;
                                  placeAutoComplete(query,
                                      locationType: 'current');
                                },
                                onTap: () {
                                  if (_hasCurrentLocation &&
                                      _pickupLocationController.text.isEmpty) {
                                    _showCurrentLocationAsSuggestion();
                                  }
                                },
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "currentLocationText".tr,
                                  border: InputBorder.none,
                                  suffixIcon: _pickupLocationController
                                          .text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _pickupLocationController.clear();
                                            controller.pickupLocation.value =
                                                '';
                                            setState(() {
                                              if (_hasCurrentLocation) {
                                                _showCurrentLocationAsSuggestion();
                                              } else {
                                                _placePredictions = [];
                                              }
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              ),
                              const Divider(
                                height: 2,
                                color: AppColors.blackLighter,
                              ),
                              // Destination
                              TextFormField(
                                controller: _destinationController,
                                focusNode: _destinationFocusNode,
                                onChanged: (query) {
                                  controller.selectedDeliveryLocation.value =
                                      query;
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
                                  suffixIcon:
                                      _destinationController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                _destinationController.clear();
                                                controller
                                                    .selectedDeliveryLocation
                                                    .value = '';
                                                setState(() {
                                                  _placePredictions = [];
                                                });
                                              },
                                            )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading)
                     Center(child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.black,
                size: 40,
              ),)
                  else
                    const SizedBox.shrink(),
                  Expanded(child: Container()),
                ],
              ),
              // Position predictions list properly
              if (_placePredictions.isNotEmpty)
                Positioned(
                  top: _locationType == 'current' ? 70 : 110,
                  left: 50, // Align with the text fields
                  right: 24,
                  child: _buildPredictionsList(),
                ),
            ],
          ),
        ),
      ),
      // Bottom bar with "Back" and "Next" buttons
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
                //! log("<================================== Tapped Next ==========================================>");
                controller.fetchDeliveryParcelsList();
                _fetchParcelsAndProceed();
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
